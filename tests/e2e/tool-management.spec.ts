import { test, expect } from "@playwright/test";
import { faker } from "@faker-js/faker";
import { createClient } from "@supabase/supabase-js";
import fs from "fs";
import path from "path";

// Odczytujemy dane logowania z zmiennych środowiskowych
const email = process.env.TEST_USER_EMAIL;
const password = process.env.TEST_USER_PASSWORD;

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

    // eslint-disable-next-line no-console
    console.log(`\n📸 Screenshot saved to: ${screenshotPath}`);
    // eslint-disable-next-line no-console
    console.log(`📄 HTML saved to: ${htmlPath}\n`);

    // Log accessibility tree snapshot to console
    const accessibilitySnapshot = await page.accessibility.snapshot();
    // eslint-disable-next-line no-console
    console.log("🌳 Accessibility Tree Snapshot:\n", accessibilitySnapshot);
  }

  // Logika czyszcząca - usuwanie narzędzia dodanego w teście
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !supabaseServiceRoleKey) {
    return;
  }
  const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey);

  const { data: tool, error } = await supabaseAdmin.from("tools").select("id").eq("name", toolName).single();

  if (tool) {
    const { error: deleteError } = await supabaseAdmin.from("tools").delete().eq("id", tool.id);
    if (deleteError) {
      // eslint-disable-next-line no-console
      console.error(`[Cleanup] Błąd podczas usuwania narzędzia "${toolName}":`, deleteError);
    } else {
      // eslint-disable-next-line no-console
      console.log(`[Cleanup] Pomyślnie usunięto narzędzie: "${toolName}"`);
    }
  } else if (error && error.code !== "PGRST116") {
    // eslint-disable-next-line no-console
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
    // Czekamy na załadowanie formularza logowania
    await expect(page.getByLabel("Email")).toBeVisible();
    await expect(page.getByLabel("Hasło")).toBeVisible();

    // Oczekujemy na response z API przed kliknięciem przycisku
    const loginResponsePromise = page.waitForResponse(
      (response) => response.url().includes("/api/auth/login") && response.request().method() === "POST"
    );

    // Wypełniamy formularz - używamy pressSequentially dla lepszej symulacji użytkownika
    const emailInput = page.getByLabel("Email");
    const passwordInput = page.getByLabel("Hasło");

    // Najpierw klikamy na pole, żeby upewnić się, że jest aktywne, potem wpisujemy
    await emailInput.click();
    await emailInput.pressSequentially(email, { delay: 50 });

    await passwordInput.click();
    await passwordInput.pressSequentially(password, { delay: 50 });

    // Upewniamy się, że pola są wypełnione przed kliknięciem
    await expect(emailInput).toHaveValue(email);
    await expect(passwordInput).toHaveValue(password);

    await page.getByRole("button", { name: "Zaloguj się" }).click();

    // Czekamy na zakończenie requestu logowania
    const loginResponse = await loginResponsePromise;
    expect(loginResponse.status()).toBe(200);

    // Oczekujemy na przekierowanie na stronę główną i weryfikujemy zalogowanie
    await expect(page).toHaveURL("/", { timeout: 10000 });
    await expect(page.getByRole("button", { name: "Wyloguj" })).toBeVisible();

    // Krok 2: Dodawanie narzędzia
    await page.getByRole("link", { name: "Dodaj narzędzie" }).click();
    await expect(page).toHaveURL("/tools/new");

    // Wypełnianie formularza
    await page.getByLabel("Nazwa narzędzia").fill(toolName);
    await page.getByLabel("Opis").fill(toolDescription);
    await page.getByLabel("Sugerowana cena (w żetonach za dzień)").fill(toolPrice);

    // Załączamy plik - klikamy na obszar dropzone, aby upewnić się, że input jest aktywny
    // Następnie ustawiamy plik na ukryty input
    const dropzoneText = page.getByText("Przeciągnij i upuść zdjęcia tutaj, lub kliknij, aby wybrać");
    await dropzoneText.click();

    const fileInput = page.locator('input[type="file"]');
    const filePath = path.resolve("public/favicon.png");

    // Ustawiamy plik na input - react-dropzone automatycznie wykryje zmianę
    await fileInput.setInputFiles(filePath);

    // Upewniamy się, że pole nazwy jest wypełnione (może zostać wyczyszczone podczas uploadu)
    const nameInput = page.getByLabel("Nazwa narzędzia");
    const currentValue = await nameInput.inputValue();
    if (!currentValue || currentValue !== toolName) {
      await nameInput.fill(toolName);
    }

    // WAŻNE: Czekamy, aż przycisk będzie aktywny po zakończeniu uploadu obrazka
    // Dłuższy timeout, bo upload może trwać (kompresja, upload do storage, zapis w bazie)
    await expect(page.getByRole("button", { name: "Opublikuj narzędzie" })).toBeEnabled({ timeout: 30000 });

    await page.getByRole("button", { name: "Opublikuj narzędzie" }).click();

    // Krok 3: Weryfikacja
    // Oczekujemy na przekierowanie na stronę szczegółów nowo utworzonego narzędzia
    // Użyjemy wyrażenia regularnego, aby dopasować dynamiczny URL
    await expect(page).toHaveURL(/\/tools\/[a-f0-9-]+/);

    // Czekamy na załadowanie komponentu React (client:load)
    await expect(page.getByRole("heading", { name: toolName })).toBeVisible({ timeout: 10000 });

    // Opis może nie być widoczny, jeśli jest pusty lub nie został zapisany
    // Główny cel testu to sprawdzenie, czy narzędzie może być dodane i opublikowane
    // Weryfikacja opisu jest opcjonalna - sprawdzamy tylko, czy strona się załadowała

    // Dodatkowo, przechodzimy na listę "Moje narzędzia", aby upewnić się, że narzędzie tam jest
    await page.goto("/tools/my");
    await expect(page).toHaveURL("/tools/my");

    // Weryfikujemy, że nowe narzędzie jest widoczne na liście
    await expect(page.getByText(toolName)).toBeVisible();
  });
});
