# Przewodnik: GitHub Actions - Testowanie i Deployment

## 📋 Co zostało utworzone?

Utworzony został workflow **CI (Continuous Integration)** dla Pull Requestów:
- ✅ Lintowanie kodu
- ✅ Testy jednostkowe z coverage
- ✅ Testy E2E
- ✅ Automatyczny komentarz w PR z wynikami

**⚠️ Ważne:** To jest workflow **CI** (testowanie), nie **CD** (deployment). Nie wdraża aplikacji produkcyjnie automatycznie.

---

## 🧪 Jak przetestować workflow?

### Krok 1: Skonfiguruj sekrety GitHub

1. Przejdź do repozytorium na GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Dodaj wszystkie wymagane sekrety:

```
SUPABASE_URL
SUPABASE_KEY
OPENROUTER_API_KEY
E2E_USERNAME_ID
E2E_USERNAME
E2E_PASSWORD
TEST_USER_EMAIL
TEST_USER_PASSWORD
```

### Krok 2: Utwórz Pull Request

```bash
# Utwórz nowy branch
git checkout -b test/workflow-ci

# Wprowadź jakąś zmianę (np. dodaj komentarz)
# ...

# Commit i push
git add .
git commit -m "test: verify CI workflow"
git push origin test/workflow-ci
```

3. Na GitHubie utwórz Pull Request do brancha `master`
4. Workflow uruchomi się automatycznie

### Krok 3: Sprawdź wyniki

1. W PR zobaczysz statusy checków:
   - ✅ Lint Code
   - ✅ Unit Tests  
   - ✅ E2E Tests

2. Po przejściu wszystkich checków, pojawi się automatyczny komentarz z:
   - Statusem wszystkich testów
   - Statystykami coverage

3. Szczegóły można zobaczyć w zakładce **Actions** na GitHubie

### Krok 4: Sprawdź artifacts

W zakładce **Actions** → wybierz uruchomienie → na dole strony znajdziesz:
- `unit-test-coverage` - raporty coverage
- `playwright-report` - raport HTML z testów E2E

---

## 🚀 Deployment produkcyjny

### Opcja 1: Vercel (Rekomendowane dla Astro)

Vercel ma natywne wsparcie dla Astro i automatyczny deployment:

1. **Połącz repozytorium z Vercel:**
   - Zaloguj się na [vercel.com](https://vercel.com)
   - **Add New Project** → wybierz repozytorium
   - Vercel automatycznie wykryje Astro

2. **Konfiguracja:**
   - **Framework Preset:** Astro
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
   - **Install Command:** `npm ci`

3. **Zmienne środowiskowe:**
   - W ustawieniach projektu dodaj wszystkie zmienne z `.env.example`
   - Użyj wartości produkcyjnych (nie testowych!)

4. **Automatyczny deployment:**
   - Każdy push do `master` → automatyczny deployment
   - Każdy PR → preview deployment

### Opcja 2: Netlify

Podobnie jak Vercel:

1. Połącz repozytorium z Netlify
2. Ustaw:
   - **Build command:** `npm run build`
   - **Publish directory:** `dist`
3. Dodaj zmienne środowiskowe
4. Automatyczny deployment z Git

### Opcja 3: GitHub Actions + VPS (DigitalOcean/Railway/Render)

Jeśli potrzebujesz pełnej kontroli, możesz utworzyć workflow deploymentu:

**Przykład workflow `deploy.yml`:**
```yaml
name: Deploy to Production

on:
  push:
    branches:
      - master

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version-file: '.nvmrc'
      - run: npm ci
      - run: npm run build
      # Tutaj dodaj kroki deploymentu (SSH, Docker, itp.)
```

---

## 🔧 Co dalej?

### 1. Dodaj workflow deploymentu (opcjonalnie)

Jeśli chcesz automatyczny deployment przez GitHub Actions, mogę utworzyć:
- `deploy.yml` - deployment do Vercel/Netlify przez CLI
- `deploy-vps.yml` - deployment do VPS (SSH/Docker)

### 2. Ulepsz workflow CI

Możesz dodać:
- **Build check** - weryfikacja czy aplikacja się buduje
- **Type checking** - `tsc --noEmit`
- **Security scanning** - npm audit, Snyk
- **Performance tests** - Lighthouse CI

### 3. Konfiguracja środowisk

Rozważ utworzenie:
- **Environment: production** - dla deploymentu
- **Environment: staging** - dla testów przed produkcją

---

## 📝 Checklist przed pierwszym uruchomieniem

- [ ] Wszystkie sekrety dodane w GitHub Settings
- [ ] Testy przechodzą lokalnie (`npm run test`, `npm run test:e2e`)
- [ ] Lint przechodzi lokalnie (`npm run lint`)
- [ ] Build działa lokalnie (`npm run build`)
- [ ] Utworzony PR do testowania workflow

---

## 🐛 Rozwiązywanie problemów

### Workflow nie uruchamia się
- Sprawdź czy plik jest w `.github/workflows/pull-request.yml`
- Sprawdź czy branch docelowy to `master` (nie `main`)

### Testy E2E failują
- Sprawdź czy wszystkie sekrety są ustawione
- Sprawdź czy środowisko testowe Supabase jest dostępne
- Zobacz logi w Actions → szczegóły joba

### Coverage nie działa
- Sprawdź czy `@vitest/coverage-v8` jest zainstalowany (workflow instaluje go automatycznie)
- Sprawdź czy testy faktycznie się uruchamiają

### Komentarz nie pojawia się w PR
- Sprawdź czy wszystkie 3 joby przeszły (lint, unit-test, e2e-test)
- Sprawdź uprawnienia GitHub Actions w Settings → Actions → General → Workflow permissions

---

## 💡 Przydatne linki

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Astro Deployment Guide](https://docs.astro.build/en/guides/deploy/)
- [Vercel Deployment](https://vercel.com/docs)
- [Netlify Deployment](https://docs.netlify.com/)

---

**Pytanie:** Chcesz, żebym utworzył workflow deploymentu produkcyjnego? Mogę przygotować:
- Deployment do Vercel przez GitHub Actions
- Deployment do Netlify przez GitHub Actions  
- Deployment do VPS (DigitalOcean/Railway/Render)

