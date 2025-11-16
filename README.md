# Masz Pan?

"Masz Pan?" is a tool-sharing platform that connects people who need tools with those who have them. It allows users to list their own tools for others to rent, as well as to search for and reserve tools they need for their projects.

## Tech Stack

- [Astro](https://astro.build/) v5.5.5 - Modern web framework for building fast, content-focused websites
- [React](https://react.dev/) v19.0.0 - UI library for building interactive components
- [TypeScript](https://www.typescriptlang.org/) v5 - Type-safe JavaScript
- [Tailwind CSS](https://tailwindcss.com/) v4.0.17 - Utility-first CSS framework
- [Supabase](https://supabase.io/) - Open source Firebase alternative for database, auth, and storage

### Testing

- [Vitest](https://vitest.dev/) - Test runner for unit and integration tests
- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/) - For testing React components
- [Supertest](https://github.com/ladjs/supertest) - For testing API endpoints
- [Playwright](https://playwright.dev/) - For end-to-end tests

## Prerequisites

- Node.js v22.14.0 (as specified in `.nvmrc`)
- npm (comes with Node.js)
- Supabase account and local CLI setup for database management.

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/your-github-username/masz-pan.git
cd masz-pan
```

2. Install dependencies:

```bash
npm install
```

3. Set up your environment variables. Copy `.env.example` to `.env` and fill in your Supabase credentials.

4. Run the development server:

```bash
npm run dev
```

5. Build for production:

```bash
npm run build
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint
- `npm run lint:fix` - Fix ESLint issues
- `npm run test` - Run all tests
- `npm run test:unit` - Run unit tests
- `npm run test:e2e` - Run end-to-end tests
- `npm run test:ci` - Run all tests in CI mode

## Project Structure

```md
.
├── src/
│   ├── layouts/    # Astro layouts
│   ├── pages/      # Astro pages
│   │   └── api/    # API endpoints
│   ├── middleware/ # Astro middleware
│   ├── db/         # Supabase client and types
│   ├── types.ts    # Shared types
│   ├── components/ # UI components (Astro & React)
│   └── lib/        # Services and helpers
├── public/         # Public assets
├── supabase/       # Supabase migrations
```

## License

MIT
