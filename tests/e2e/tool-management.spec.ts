import { test, expect } from "@playwright/test";
import { faker } from "@faker-js/faker";
import { createClient } from "@supabase/supabase-js";
import fs from "fs";
import path from "path";

// Odczytujemy dane logowania z zmiennych środowiskowych
const email = process.env.TEST_USER_EMAIL!;
const password = process.env.TEST_USER_PASSWORD!;

// Upewniamy się, że zmienne są ustawione
if (!email || !password) {
  throw new Error("Zmienne środowiskowe TEST_USER_EMAIL i TEST_USER_PASSWORD muszą być ustawione w pliku .env.test");
}

const toolName = `Testowa wiertarka ${faker.string.uuid()}`;
const toolDescription = faker.lorem.paragraph();
const toolPrice = faker.number.int({ min: 1, max: 5 }).toString();

test.afterEach(async ({ page }, testInfo) => {
  // Debugging: If test fails, save screenshot and HTML
  if (testInfo.status !== testInfo.expectedStatus) {
    // Create test-results directory if it doesn't exist
    const testResultsDir = "test-results";
    if (!fs.existsSync(testResultsDir)) {
      fs.mkdirSync(testResultsDir);
    }

    const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
    const screenshotPath = path.join(testResultsDir, `failure-screenshot-${timestamp}.png`);
    const htmlPath = path.join(testResultsDir, `failure-page-${timestamp}.html`);

    await page.screenshot({ path: screenshotPath, fullPage: true });
    fs.writeFileSync(htmlPath, await page.content());

    console.log(`\n📸 Screenshot saved to: ${screenshotPath}`);
    console.log(`📄 HTML saved to: ${htmlPath}\n`);

    // Log accessibility tree snapshot to console
    const accessibilitySnapshot = await page.accessibility.snapshot();
    console.log("🌳 Accessibility Tree Snapshot:\n", accessibilitySnapshot);
  }

  // Logika czyszcząca - usuwanie narzędzia dodanego w teście
  const supabaseAdmin = createClient(process.env.PUBLIC_SUPABASE_URL!, process.env.SUPABASE_SERVICE_ROLE_KEY!);

  const { data: tool, error } = await supabaseAdmin.from("tools").select("id").eq("name", toolName).single();

  if (tool) {
    const { error: deleteError } = await supabaseAdmin.from("tools").delete().eq("id", tool.id);
    if (deleteError) {
      console.error(`[Cleanup] Błąd podczas usuwania narzędzia "${toolName}":`, deleteError);
    } else {
      console.log(`[Cleanup] Pomyślnie usunięto narzędzie: "${toolName}"`);
    }
  } else if (error && error.code !== "PGRST116") {
    console.error(`[Cleanup] Błąd podczas wyszukiwania narzędzia "${toolName}":`, error);
  }
});

test.beforeEach(async ({ page }) => {
  // Krok 0: Upewnij się, że jesteśmy wylogowani przed rozpoczęciem testu
  await page.goto("/auth/logout");
  await expect(page).toHaveURL("/auth/login");
});

test.describe("Zarządzanie narzędziami przez zalogowanego użytkownika", () => {
  test("powinien pozwolić na zalogowanie i dodanie nowego narzędzia", async ({ page }) => {
    // Krok 1: Logowanie
    await page.getByLabel("Email").fill(email);
    await page.getByLabel("Hasło").fill(password);
    await page.getByRole("button", { name: "Zaloguj się" }).click();

    // Oczekujemy na przekierowanie na stronę główną i weryfikujemy zalogowanie
    await expect(page).toHaveURL("/");
    await expect(page.getByRole("button", { name: "Wyloguj" })).toBeVisible();

    // Krok 2: Dodawanie narzędzia
    await page.getByRole("link", { name: "Dodaj narzędzie" }).click();
    await expect(page).toHaveURL("/tools/new");

    // Wypełnianie formularza
    await page.getByLabel("Nazwa narzędzia").fill(toolName);
    await page.getByLabel("Opis").fill(toolDescription);
    await page.getByLabel("Sugerowana cena (w żetonach za dzień)").fill(toolPrice);

    // Załączamy plik
    const fileInput = page.locator('input[type="file"]');
    await fileInput.setInputFiles("public/favicon.png");

    // WAŻNE: Czekamy, aż przycisk będzie aktywny po zakończeniu uploadu obrazka
    await expect(page.getByRole("button", { name: "Opublikuj narzędzie" })).toBeEnabled();

    await page.getByRole("button", { name: "Opublikuj narzędzie" }).click();

    // Krok 3: Weryfikacja
    // Oczekujemy na przekierowanie na stronę szczegółów nowo utworzonego narzędzia
    // Użyjemy wyrażenia regularnego, aby dopasować dynamiczny URL
    await expect(page).toHaveURL(/\/tools\/[a-f0-9-]+/);

    // Weryfikujemy, że nazwa i opis narzędzia są widoczne na stronie szczegółów
    await expect(page.getByRole("heading", { name: toolName })).toBeVisible();
    await expect(page.getByText(toolDescription)).toBeVisible();

    // Dodatkowo, przechodzimy na listę "Moje narzędzia", aby upewnić się, że narzędzie tam jest
    await page.goto("/tools/my");
    await expect(page).toHaveURL("/tools/my");

    // Weryfikujemy, że nowe narzędzie jest widoczne na liście
    await expect(page.getByText(toolName)).toBeVisible();
  });
});
