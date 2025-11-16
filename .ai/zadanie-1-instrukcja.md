# Zadanie 1: Pull Request Workflow - Instrukcja Wykonania

## 🎯 Cel zadania

Zabezpieczenie brancha `master` poprzez weryfikowanie wszystkich Pull Requestów za pomocą workflow CI/CD.

## ✅ Co zostało przygotowane?

Workflow już istnieje w `.github/workflows/pull-request.yml` i zawiera:
- ✅ Linting kodu (ESLint)
- ✅ Unit testy z coverage
- ✅ Testy E2E (opcjonalnie)
- ✅ Automatyczny komentarz w PR z wynikami

## 📝 Krok po kroku - Jak wprowadzić workflow na master

### Krok 1: Sprawdź czy workflow jest gotowy

```bash
# Sprawdź czy plik istnieje
cat .github/workflows/pull-request.yml

# Sprawdź czy jesteś na master
git branch --show-current
```

### Krok 2: Dodaj workflow do repozytorium (jeśli jeszcze nie jest)

```bash
# Sprawdź status
git status

# Jeśli workflow nie jest jeszcze w repozytorium, dodaj go
git add .github/workflows/pull-request.yml
git commit -m "ci: add pull request workflow with lint, tests and e2e"
git push origin master
```

### Krok 3: Skonfiguruj sekrety GitHub

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
PUBLIC_SUPABASE_URL
PUBLIC_SUPABASE_ANON_KEY
```

### Krok 4: Przetestuj workflow lokalnie (zgodnie z wymaganiami szkolenia)

#### Testowanie lintingu:

```bash
# Uruchom linting lokalnie
npm run lint

# Jeśli są błędy, możesz je naprawić automatycznie
npm run lint:fix
```

#### Testowanie unit testów:

```bash
# Uruchom testy jednostkowe
npm run test

# Uruchom testy z coverage
npm run test -- --coverage

# Sprawdź raport coverage (otworzy się w przeglądarce)
# Pliki znajdują się w folderze coverage/
```

#### Testowanie E2E:

```bash
# Upewnij się, że masz plik .env.test z odpowiednimi zmiennymi
# Skopiuj .env.example do .env.test i uzupełnij wartości testowe

# Uruchom testy E2E
npm run test:e2e

# Zobacz raport HTML (otworzy się automatycznie po zakończeniu)
```

#### Testowanie builda:

```bash
# Sprawdź czy aplikacja się buduje
npm run build

# Sprawdź czy build działa lokalnie
npm run preview
```

### Krok 5: Utwórz Pull Request do testowania

```bash
# Utwórz nowy branch
git checkout -b test/workflow-ci

# Wprowadź jakąś zmianę (np. dodaj komentarz w kodzie)
# ...

# Commit i push
git add .
git commit -m "test: verify CI workflow"
git push origin test/workflow-ci
```

3. Na GitHubie utwórz Pull Request do brancha `master`
4. Workflow uruchomi się automatycznie

### Krok 6: Sprawdź wyniki

1. W PR zobaczysz statusy checków:
   - ✅ Lint Code
   - ✅ Unit Tests  
   - ✅ E2E Tests

2. Po przejściu wszystkich checków, pojawi się automatyczny komentarz z:
   - Statusem wszystkich testów
   - Statystykami coverage

3. Szczegóły można zobaczyć w zakładce **Actions** na GitHubie

## 🔍 Weryfikacja jakości akcji (zgodnie z wymaganiami szkolenia)

### Testowanie z narzędziami terminalowymi:

#### 1. Sprawdź składnię YAML workflow:

```bash
# Użyj yamllint (jeśli masz zainstalowany)
yamllint .github/workflows/pull-request.yml

# Lub użyj online validatora:
# https://www.yamllint.com/
```

#### 2. Sprawdź czy workflow jest poprawny:

```bash
# Sprawdź czy plik istnieje i jest czytelny
cat .github/workflows/pull-request.yml

# Sprawdź czy nie ma błędów składniowych (PowerShell)
Get-Content .github/workflows/pull-request.yml | Select-String -Pattern "error|Error|ERROR"
```

#### 3. Testuj każdy krok workflow lokalnie:

```bash
# Krok 1: Linting
npm run lint

# Krok 2: Unit testy
npm run test -- --coverage

# Krok 3: E2E testy
npm run test:e2e

# Krok 4: Build
npm run build
```

#### 4. Sprawdź logi GitHub Actions:

Po uruchomieniu workflow na GitHubie:
- Przejdź do **Actions** → wybierz uruchomienie
- Sprawdź logi każdego joba
- Zwróć uwagę na:
  - Czy wszystkie kroki się wykonują
  - Czy nie ma błędów
  - Czy artifacts są uploadowane

## ✅ Certyfikacja - Checklist

Przed certyfikacją upewnij się, że:

- [ ] Workflow jest w `.github/workflows/pull-request.yml`
- [ ] Workflow reaguje na Pull Requesty do `master`
- [ ] Wykonuje ocenę jakości (linting)
- [ ] Wykonuje unit testy
- [ ] (Opcjonalnie) Wykonuje testy E2E
- [ ] Wszystkie testy przechodzą lokalnie
- [ ] Workflow działa na GitHubie (przetestowane przez PR)
- [ ] Komentarz w PR pojawia się po przejściu wszystkich checków

## 🐛 Rozwiązywanie problemów

### Workflow nie uruchamia się
- Sprawdź czy plik jest w `.github/workflows/pull-request.yml`
- Sprawdź czy branch docelowy to `master` (nie `main`)
- Sprawdź czy workflow jest w repozytorium (commit i push)

### Testy failują lokalnie
- Sprawdź czy wszystkie zależności są zainstalowane (`npm ci`)
- Sprawdź czy zmienne środowiskowe są ustawione
- Sprawdź logi błędów w terminalu

### Testy failują na GitHubie
- Sprawdź czy wszystkie sekrety są ustawione w GitHub Settings
- Sprawdź logi w Actions → szczegóły joba
- Porównaj z wynikami lokalnymi

## 📚 Przydatne komendy

```bash
# Sprawdź strukturę workflow
tree .github/workflows

# Sprawdź status git
git status

# Sprawdź historię commitów
git log --oneline -5

# Sprawdź czy workflow jest w repozytorium
git ls-files .github/workflows/
```

## 🎓 Podsumowanie dla certyfikacji

Workflow jest gotowy i zawiera:
1. ✅ Reagowanie na Pull Requesty do `master`
2. ✅ Ocena jakości - linting (ESLint)
3. ✅ Unit testy z coverage
4. ✅ (Opcjonalnie) Testy E2E
5. ✅ Automatyczny komentarz w PR

**Następne kroki:**
1. Wprowadź workflow na master (commit i push)
2. Skonfiguruj sekrety GitHub
3. Przetestuj przez utworzenie PR
4. Zweryfikuj wyniki

