# CoachLoop

AI sales-call coaching loop. Paste a call transcript, get back specific, actionable coaching.

> 🛠️ **Built during [Claude Build Day](https://cerebralvalley.ai/e/claude-startups-build-day)** (Anthropic + Cerebral Valley) — San Francisco, 2026-06-13. Open source under MIT. Everything in this repo was built at the event.

## Stack

- **Next.js** (App Router) + **TypeScript**
- **Anthropic SDK** — Claude **Opus 4.8** (`claude-opus-4-8`) for scoring/coaching/re-score
- **ElevenLabs Agents** — realtime voice drill, Claude as the brain
- **Tailwind CSS + shadcn/ui** — mobile-first component layer
- **Neon Postgres**

## Quickstart (fork-and-run)

Fork it, add your own keys, run the whole loop on your own accounts:

```bash
npm install
cp .env.example .env   # fill in ANTHROPIC_API_KEY, ELEVENLABS_API_KEY, ELEVENLABS_AGENT_ID, DATABASE_URL
npm run dev            # http://localhost:3000
```

All four env vars are required — see [`.env.example`](.env.example).

## Scripts

| Command | Description |
| --- | --- |
| `npm run dev` | Start the dev server |
| `npm run build` | Production build |
| `npm run start` | Serve the production build |
| `npm run lint` | ESLint |
| `npm run typecheck` | `tsc --noEmit` |

## Configuration

All declared variables live in [`src/config.ts`](src/config.ts) — hackathon metadata, the
target model (`MODEL`), and the `ANTHROPIC_API_KEY` accessor. The only required secret is
`ANTHROPIC_API_KEY` (see `.env.example`).

## License

[MIT](LICENSE) © Seb Vargas
