/**
 * Minimal example: call the ICLR LiteLLM proxy via native fetch (Node 20+).
 *
 * Usage:
 *     source .env
 *     npx tsx examples/sdk_typescript.ts
 */

function main(): void {
  const base = process.env.HERMES_API_BASE;
  const key = process.env.HERMES_API_KEY;
  const model = process.env.HERMES_MODEL_ALIAS || "reasoning";

  if (!base || !key) {
    console.error("Error: HERMES_API_BASE and HERMES_API_KEY must be set (source .env).");
    process.exit(1);
  }

  const url = `${base}/chat/completions`;
  const payload = {
    model,
    max_tokens: 256,
    messages: [{ role: "user", content: "Say 'hello'" }],
  };

  fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  })
    .then((resp: Response) => {
      if (!resp.ok) throw new Error(`HTTP ${resp.status}: ${resp.statusText}`);
      return resp.json();
    })
    .then((data: any) => console.log(data.choices[0].message.content))
    .catch((e: Error) => {
      console.error(e);
      process.exit(1);
    });
}

main();
