# Deployment do Vercel przez GitHub Actions - Instrukcja

## 📋 Co zostało utworzone?

Utworzony został workflow `.github/workflows/deploy-vercel.yml` który:
- ✅ Automatycznie wdraża aplikację do Vercel przy pushu do `master`
- ✅ Buduje aplikację przed deploymentem
- ✅ Używa środowiska `production` z ochroną
- ✅ Można uruchomić ręcznie przez `workflow_dispatch`

## 🚀 Konfiguracja Vercel

### Krok 1: Utwórz projekt w Vercel

1. Zaloguj się na [vercel.com](https://vercel.com)
2. Przejdź do **Dashboard** → **Add New Project**
3. Wybierz repozytorium GitHub
4. Vercel automatycznie wykryje Astro

### Krok 2: Pobierz identyfikatory projektu

Po utworzeniu projektu w Vercel:

1. Przejdź do **Settings** → **General**
2. Znajdź:
   - **Project ID** - skopiuj ten identyfikator
   - **Team ID** (Organization ID) - jeśli używasz teamu, skopiuj ten identyfikator

### Krok 3: Utwórz Vercel Token

1. Przejdź do [Vercel Account Settings](https://vercel.com/account/tokens)
2. Kliknij **Create Token**
3. Nadaj nazwę (np. "GitHub Actions Deploy")
4. Wybierz scope: **Full Account** lub **Specific Projects**
5. Skopiuj wygenerowany token (będzie widoczny tylko raz!)

### Krok 4: Skonfiguruj sekrety GitHub

W repozytorium GitHub:

1. **Settings** → **Secrets and variables** → **Actions**
2. Dodaj następujące sekrety:

```
VERCEL_TOKEN          # Token z Vercel (Krok 3)
VERCEL_ORG_ID         # Team/Organization ID (Krok 2)
VERCEL_PROJECT_ID     # Project ID (Krok 2)
```

**Dodatkowo** (jeśli jeszcze nie masz):
```
SUPABASE_URL
SUPABASE_KEY
OPENROUTER_API_KEY
PUBLIC_SUPABASE_URL
PUBLIC_SUPABASE_ANON_KEY
```

### Krok 5: Skonfiguruj Environment w Vercel

1. W Vercel Dashboard → **Settings** → **Environment Variables**
2. Dodaj wszystkie zmienne produkcyjne z `.env.example`:
   - `SUPABASE_URL` (produkcyjna wartość)
   - `SUPABASE_KEY` (produkcyjna wartość)
   - `OPENROUTER_API_KEY` (produkcyjna wartość)
   - `PUBLIC_SUPABASE_URL` (produkcyjna wartość)
   - `PUBLIC_SUPABASE_ANON_KEY` (produkcyjna wartość)

**Ważne:** Użyj wartości **produkcyjnych**, nie testowych!

### Krok 6: Skonfiguruj Environment Protection (opcjonalnie)

W GitHub:

1. **Settings** → **Environments** → **New environment**
2. Nazwa: `production`
3. Włącz **Required reviewers** (jeśli chcesz wymagać zatwierdzenia przed deploymentem)
4. Zapisz

## 🧪 Testowanie deploymentu

### Opcja 1: Automatyczny deployment (push do master)

```bash
# Upewnij się, że jesteś na master
git checkout master

# Wprowadź zmianę
echo "# Test deployment" >> README.md

# Commit i push
git add README.md
git commit -m "test: trigger Vercel deployment"
git push origin master
```

Workflow uruchomi się automatycznie i wdroży aplikację.

### Opcja 2: Ręczne uruchomienie

1. Przejdź do **Actions** na GitHubie
2. Wybierz workflow **Deploy to Vercel**
3. Kliknij **Run workflow**
4. Wybierz branch `master`
5. Kliknij **Run workflow**

## 🔍 Weryfikacja deploymentu

### Sprawdź status workflow:

1. Przejdź do **Actions** na GitHubie
2. Wybierz uruchomienie workflow **Deploy to Vercel**
3. Sprawdź czy wszystkie kroki przeszły:
   - ✅ Checkout code
   - ✅ Setup Node.js
   - ✅ Install dependencies
   - ✅ Build application
   - ✅ Install Vercel CLI
   - ✅ Pull Vercel Environment Information
   - ✅ Build Project Artifacts
   - ✅ Deploy Project Artifacts to Vercel

### Sprawdź deployment w Vercel:

1. Przejdź do Vercel Dashboard
2. Wybierz projekt
3. W zakładce **Deployments** zobaczysz najnowszy deployment
4. Kliknij na deployment, aby zobaczyć szczegóły

### Sprawdź URL aplikacji:

Po udanym deploymentzie:
- URL znajdziesz w Vercel Dashboard → **Deployments** → najnowszy deployment
- URL jest również dostępny w GitHub Actions → **Deploy to Vercel Production** → **production** (link w sekcji environment)

## 🐛 Rozwiązywanie problemów

### Błąd: "Vercel CLI not found"
- Workflow instaluje Vercel CLI automatycznie, sprawdź czy krok się wykonuje

### Błąd: "Invalid token"
- Sprawdź czy `VERCEL_TOKEN` jest poprawnie ustawiony w sekretach GitHub
- Sprawdź czy token nie wygasł

### Błąd: "Project not found"
- Sprawdź czy `VERCEL_PROJECT_ID` jest poprawny
- Sprawdź czy `VERCEL_ORG_ID` jest poprawny (jeśli używasz teamu)

### Błąd: "Build failed"
- Sprawdź logi builda w GitHub Actions
- Sprawdź czy wszystkie zmienne środowiskowe są ustawione w Vercel
- Sprawdź czy build działa lokalnie (`npm run build`)

### Deployment się nie uruchamia
- Sprawdź czy workflow jest w branchu `master`
- Sprawdź czy plik `.github/workflows/deploy-vercel.yml` istnieje
- Sprawdź czy workflow ma uprawnienia do uruchomienia

## 📝 Konfiguracja zaawansowana

### Dodaj preview deployments dla PR:

Możesz rozszerzyć workflow o preview deployments:

```yaml
on:
  pull_request:
    branches:
      - master
```

I dodać logikę do rozróżnienia między production a preview.

### Dodaj notyfikacje:

Możesz dodać powiadomienia o statusie deploymentu:
- Slack
- Discord
- Email

### Dodaj rollback:

W Vercel Dashboard możesz łatwo zrobić rollback do poprzedniego deploymentu.

## ✅ Checklist przed pierwszym deploymentem

- [ ] Projekt utworzony w Vercel
- [ ] `VERCEL_TOKEN` dodany do sekretów GitHub
- [ ] `VERCEL_ORG_ID` dodany do sekretów GitHub
- [ ] `VERCEL_PROJECT_ID` dodany do sekretów GitHub
- [ ] Zmienne środowiskowe ustawione w Vercel (produkcyjne wartości)
- [ ] Build działa lokalnie (`npm run build`)
- [ ] Workflow jest w branchu `master`
- [ ] Test deploymentu wykonany

## 💡 Przydatne linki

- [Vercel CLI Documentation](https://vercel.com/docs/cli)
- [Vercel GitHub Actions](https://vercel.com/docs/integrations/github-actions)
- [Vercel Environment Variables](https://vercel.com/docs/projects/environment-variables)

## 🎯 Podsumowanie

Workflow deploymentu jest gotowy i będzie:
1. ✅ Automatycznie wdrażać przy pushu do `master`
2. ✅ Budować aplikację przed deploymentem
3. ✅ Używać zmiennych środowiskowych z Vercel
4. ✅ Pokazywać URL deploymentu w GitHub Actions

**Następne kroki:**
1. Skonfiguruj Vercel (projekt, token, zmienne)
2. Dodaj sekrety do GitHub
3. Wykonaj test deploymentu
4. Zweryfikuj działanie aplikacji

