/// Assistant configuration flags.
///
/// [kAssistantDemoMode] swaps the real backend proxy client for a local,
/// no-network **demo** model so the whole UX can be exercised on-device without
/// an API key or a running backend. Reads run against your REAL data; a write
/// shows the real confirm card. Flip this to `false` once a real model is wired
/// (LLM_PROVIDER + key on the backend) to route through `/v1/ai/chat` instead.
const bool kAssistantDemoMode = true;
