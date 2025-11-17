import { test, expect } from "@playwright/test";

test.describe("Smoke Test", () => {
  test("powinien poprawnie wyświetlić stronę logowania", async ({ page }) => {
    await page.goto("/auth/login");

    // Szukamy elementu, który jest tytułem karty logowania.
    // Używamy bardziej precyzyjnego selektora bazującego na klasach CSS,
    // ponieważ "Zaloguj się" nie jest formalnym nagłówkiem (rolą 'heading').
    const title = page.locator(".font-semibold.tracking-tight.text-2xl");

    // Weryfikujemy, że tytuł jest widoczny i zawiera poprawny tekst.
    await expect(title).toBeVisible();
    await expect(title).toContainText("Zaloguj się");
  });
});
