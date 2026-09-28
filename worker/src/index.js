const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type,Authorization"
};

function json(data, status = 200) {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      ...corsHeaders
    }
  });
}

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    const url = new URL(request.url);

    if (url.pathname === "/health") {
      return json({
        status: "ok",
        service: "cloudflare-enterprise-security-ai-worker",
        environment: env.ENVIRONMENT || "unknown"
      });
    }

    if (url.pathname === "/api/echo") {
      return json({
        message: "Request processed at the Cloudflare edge",
        method: request.method,
        colo: request.cf?.colo || null,
        country: request.cf?.country || null,
        ray: request.headers.get("cf-ray")
      });
    }

    if (url.pathname === "/security/analyze" && request.method === "POST") {
      let body;

      try {
        body = await request.json();
      } catch {
        return json({ error: "Request body must be valid JSON" }, 400);
      }

      const event = body.event || "No security event supplied";
      const severity = body.severity || "unknown";

      const prompt = [
        "You are a cloud security triage assistant.",
        "Analyze the following security event.",
        "Return concise JSON-like text containing: risk, rationale, recommended_action.",
        `Severity: ${severity}`,
        `Event: ${event}`
      ].join("\n");

      try {
        const result = await env.AI.run(
          "@cf/meta/llama-3.1-8b-instruct",
          { prompt }
        );

        return json({
          service: "Workers AI",
          model: "@cf/meta/llama-3.1-8b-instruct",
          input: { event, severity },
          analysis: result.response ?? result
        });
      } catch (error) {
        return json({
          error: "Workers AI inference failed",
          detail: error instanceof Error ? error.message : String(error)
        }, 502);
      }
    }

    return json({
      error: "Not found",
      endpoints: ["/health", "/api/echo", "/security/analyze"]
    }, 404);
  }
};
