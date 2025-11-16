# Quick Start Checklist - GitHub Actions & Vercel Deployment

## ✅ Zadanie 1: Pull Request Workflow

### 1. Wprowadź workflow na master

```bash
# Sprawdź czy jesteś na master
git branch --show-current

# Dodaj workflow do repozytorium
git add .github/workflows/pull-request.yml
git commit -m "ci: add pull request workflow with lint, tests and e2e"
git push origin master
```

### 2. Skonfiguruj sekrety GitHub

**Settings** → **Secrets and variables** → **Actions** → Dodaj:

```
SUPABASE_URL
SUPABASE_KEY
OPENROUTER_API_KEY
E2E_USERNAME_ID
E2E_USERNAME
E2E_PASSWORD
TEST_USER_EMAIL
TEST_USER_PASSWORD
PUBLIC_SUPABASE_URL
PUBLIC_SUPABASE_ANON_KEY
```

### 3. Przetestuj lokalnie

```bash
# Linting
npm run lint

# Unit testy z coverage
npm run test -- --coverage

# E2E testy
npm run test:e2e

# Build
npm run build
```

### 4. Utwórz testowy PR

```bash
git checkout -b test/workflow-ci
# Wprowadź zmianę
git add .
git commit -m "test: verify CI workflow"
git push origin test/workflow-ci
```

Utwórz PR na GitHubie → workflow uruchomi się automatycznie.

---

## ✅ Deployment do Vercel

### 1. Utwórz projekt w Vercel

1. [vercel.com](https://vercel.com) → **Add New Project**
2. Wybierz repozytorium
3. Skopiuj **Project ID** i **Team ID** (jeśli używasz teamu)

### 2. Utwórz Vercel Token

1. [Vercel Account Settings](https://vercel.com/account/tokens) → **Create Token**
2. Skopiuj token (widoczny tylko raz!)

### 3. Dodaj sekrety GitHub

**Settings** → **Secrets and variables** → **Actions** → Dodaj:

```
VERCEL_TOKEN
VERCEL_ORG_ID        # Team ID (jeśli używasz teamu)
VERCEL_PROJECT_ID
```

### 4. Skonfiguruj zmienne w Vercel

**Vercel Dashboard** → **Settings** → **Environment Variables** → Dodaj:

```
SUPABASE_URL          # Produkcyjna wartość
SUPABASE_KEY          # Produkcyjna wartość
OPENROUTER_API_KEY    # Produkcyjna wartość
PUBLIC_SUPABASE_URL   # Produkcyjna wartość
PUBLIC_SUPABASE_ANON_KEY  # Produkcyjna wartość
```

### 5. Wprowadź workflow deploymentu

```bash
git add .github/workflows/deploy-vercel.yml
git commit -m "ci: add Vercel deployment workflow"
git push origin master
```

### 6. Test deploymentu

Workflow uruchomi się automatycznie przy pushu do `master`.

Lub ręcznie: **Actions** → **Deploy to Vercel** → **Run workflow**

---

## 📋 Podsumowanie - Co zostało utworzone?

### Workflow CI (Pull Request):
- ✅ `.github/workflows/pull-request.yml`
  - Linting
  - Unit testy z coverage
  - E2E testy
  - Komentarz w PR

### Workflow CD (Deployment):
- ✅ `.github/workflows/deploy-vercel.yml`
  - Automatyczny deployment do Vercel
  - Build przed deploymentem
  - Environment protection

### Dokumentacja:
- ✅ `.ai/zadanie-1-instrukcja.md` - Szczegółowa instrukcja zadania 1
- ✅ `.ai/deploy-vercel-instrukcja.md` - Instrukcja deploymentu Vercel
- ✅ `.ai/github-actions-setup-guide.md` - Ogólny przewodnik

---

## 🎯 Następne kroki

1. ✅ Wprowadź workflow PR na master
2. ✅ Skonfiguruj sekrety GitHub
3. ✅ Przetestuj workflow przez PR
4. ✅ Skonfiguruj Vercel
5. ✅ Wprowadź workflow deploymentu
6. ✅ Przetestuj deployment

**Gotowe!** 🚀

