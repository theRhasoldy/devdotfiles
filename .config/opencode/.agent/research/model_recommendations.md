# AI Model Recommendations for Coding Workflows

Based on the "opencode go" subscription (which provides access to top-tier models like Gemini 1.5/2.0 Pro/Flash, Claude 3.5 Sonnet, GPT-4o, and OpenAI o1), here are the optimal model choices tailored specifically to your four workflows.

## 1. Complex Apps (Planning & Execution)
*Researching competitors, UI/UX, system design, DB architecture, and context-aware frontend coding.*

*   **Planning & Architecture:** **OpenAI o1**
    *   *Why:* o1's chain-of-thought processing excels at complex, multi-step reasoning. It is ideal for system design, database schema planning, and architecting full-stack applications from scratch where robust logic and structure are paramount.
*   **Execution & Coding:** **Claude 3.5 Sonnet**
    *   *Why:* Claude 3.5 Sonnet consistently leads in software engineering benchmarks (like SWE-bench). It is widely recognized as the best model for UI/UX frontend coding, cleanly adhering to existing project rules, hooks, and context without hallucinating out-of-scope changes.

## 2. Vision-to-Code (Fast)
*Translating screenshots, videos, or Figma designs into actual code with extreme speed and multimodal capability.*

*   **Primary Recommendation:** **Gemini 2.0 Flash** (or Gemini 1.5 Flash)
    *   *Why:* Gemini Flash models are engineered for low-latency speed and native multimodality. They can process video frames natively and parse complex UI screenshots rapidly. For a workflow where speed is critical, Flash provides near-instant vision-to-code translations.
*   **Alternative (Static Images):** **GPT-4o**
    *   *Why:* GPT-4o has exceptional vision capabilities for static images and is very fast, making it highly reliable for converting a single UI mockup or Figma screenshot into pixel-perfect React/Tailwind components.

## 3. Deep Analysis & Refactoring
*Deep analysis of a project for optimization and refactoring, requiring massive context windows.*

*   **Primary Recommendation:** **Gemini 1.5 Pro / 2.0 Pro**
    *   *Why:* With a massive 1-2 million token context window, Gemini Pro can ingest entire repositories, extensive documentation, and logs simultaneously. It has unmatched recall capabilities for identifying refactoring opportunities and cross-file dependencies across widespread codebases.
*   **Secondary Recommendation:** **Claude 3.5 Sonnet**
    *   *Why:* While its context window is smaller (200k), its code comprehension and refactoring intuition are top-tier. Use Claude if the codebase subset fits within 200k tokens and requires intricate logical restructuring.

## 4. Studying & Tutoring
*Challenging the user to recreate problems and guiding them to optimal solutions.*

*   **Primary Recommendation:** **OpenAI o1** (or o1-mini)
    *   *Why:* o1 understands the core computer science concepts behind problems deeply. It can be prompted to use the Socratic method—evaluating your logic, pointing out flaws in your approach, and guiding you step-by-step to arrive at the optimal solution yourself rather than just spitting out the code.
*   **Secondary Recommendation:** **GPT-4o**
    *   *Why:* GPT-4o has a highly conversational, adaptable persona. With a good system prompt (e.g., "Act as a strict but helpful programming tutor..."), it excels at maintaining a natural back-and-forth dialogue to challenge your assumptions.
