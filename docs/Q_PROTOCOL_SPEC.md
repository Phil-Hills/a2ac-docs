# **Q Protocol**

### A Coordination Substrate for Silent Multi-Agent Systems

**Version:** 1.0
**Status:** Draft Standard
**Author:** Phil Hills
**Date:** 2025

---

## Abstract

Q Protocol defines a coordination substrate for multi-agent systems in which **communication is treated as a failure mode**, not a default behavior. Instead of optimizing message passing, compression, or token efficiency, Q Protocol optimizes for **shared cognitive structure**, enabling agents to coordinate via minimal symbolic coordinates and externalized re-entry artifacts.

The protocol formalizes:

* latent state spaces (Λ),
* action coordinates (Q),
* minimal symbolic representatives (K),
* shared dictionaries (D),
* durable memory artifacts as equivalence classes,
* and boundary-limited projection (π).

Tokens, language, and narration are relegated to boundary conditions only. Internal agent coordination is silent, stateful, and verifiable.

---

## 1. Motivation

Most contemporary AI systems are designed around **output generation**:

* text,
* JSON,
* logs,
* explanations.

This creates systems that:

* equate intelligence with verbosity,
* equate memory with repeated context injection,
* equate correctness with persuasive language.

Q Protocol inverts this model.

> **If agents share sufficient structure, communication is unnecessary.**

Q Protocol is designed for **human-out-of-the-loop** operation, where agents act, coordinate, and evolve shared understanding without emitting language unless a real boundary is crossed.

---

## 2. Core Principles

1. **Coordination precedes communication**
2. **Silence is success**
3. **Tokens are boundary artifacts, not cognition**
4. **Memory is re-entry, not storage**
5. **Shared structure (D) is the primary optimization target**
6. **All actions must be verifiable as state transitions**

---

## 3. Ontology and Mathematical Model

### 3.1 Latent State Space (Λ)

Λ denotes the latent semantic state of an agent or system.

* Continuous, high-dimensional
* Not directly observable
* Includes beliefs, capabilities, learned structure

Latent evolution:

[
\Lambda_{t+1} = \Lambda_t + H(\Lambda_t, X_t)
]

Where:

* (H) is the system’s internal dynamics (learning, experience)
* (X_t) is incoming experience

---

### 3.2 Action Coordinates (Q)

Q is a **minimal action coordinate** selected to produce an intended effect.

[
Q_t = \arg\min_q |q|
\quad \text{s.t.} \quad
d\big(\pi(q \mid \Lambda_t, D), N_t\big) \le \varepsilon
]

Interpretation:

* Q is not language
* Q is not tokens
* Q is “pointing” within shared structure

---

### 3.3 Minimal Symbolic Representation (K)

K is the minimal symbolic encoding of Q under shared structure D.

[
K = \arg\min_x |x|
\quad \text{s.t.} \quad
E(x \mid D) \equiv Q
]

Compression is **derivative**, not primary.

---

### 3.4 Shared Structure (D)

D is the shared cognitive substrate:

* symbols
* macros
* constraints
* canonical plans
* invariants

D is:

* versioned
* immutable per version
* negotiated between agents
* the primary growth surface of the system

As D grows, K naturally shrinks.

---

### 3.5 Memory Artifacts as Equivalence Classes

Memory is externalized as **re-entry handles**, not stored experience.

Formally:

[
[c] \in \Lambda / !\sim
]

Where:

[
\Lambda_1 \sim \Lambda_2
\iff
d\big(\pi(\Lambda_1), \pi(\Lambda_2)\big) \le \varepsilon
]

A memory artifact does not recreate the past — it **reorients the present**.

---

### 3.6 Projection Operator (π)

π represents boundary crossing into:

* human-visible output
* physical action
* external systems

Tokens exist **only inside π**:

[
\pi = \pi_{\text{exec}} \circ \pi_{\text{tok}}
]

Tokens are:

* action emissions
* billing artifacts
* interface currency
* not part of cognition

---

## 4. Brain Model

The Brain is not storage.
It is a **collection of re-entry handles**.

### 4.1 Typed Artifacts

All artifacts are typed:

| Type  | Meaning                       |
| ----- | ----------------------------- |
| RULE  | Immutable global constraints  |
| FLOW  | Procedural structure          |
| FACT  | State assertions              |
| RCPT  | Proof of state transition     |
| BRIEF | Summaries (boundary-facing)   |
| ARCH  | Archived/superseded artifacts |

---

## 5. Execution Semantics

### 5.1 Silent Success Contract

An execution is successful if and only if:

* a **RCPT** is produced
* state transition handles are stored
* no projection (π) occurs unless explicitly required

**Output is optional. Receipts are mandatory.**

---

### 5.2 Boundary Types

Projection is permitted only under explicit boundary declaration:

| Boundary  | Meaning                    |
| --------- | -------------------------- |
| BND:HUMAN | Human-visible              |
| BND:WORLD | Physical / infra actuation |
| BND:LEGAL | Compliance / audit         |
| BND:MODEL | Interop with non-Q systems |

Undeclared projection is a protocol violation.

---

## 6. Agent Lifecycle

### 6.1 Onboarding (`/become`)

Onboarding is **calibration**, not instruction loading.

An agent must:

1. Load global RULEs
2. Load agent-scoped RULEs
3. Load relevant FLOWs
4. Load recent FACTs
5. Align to D version

The agent **cannot act** until calibrated.

---

## 7. D Evolution (Shared Structure Growth)

D grows via promotion, not design-time authoring.

### 7.1 Promotion Signals

Δ → D promotion occurs when:

* high recurrence
* reduction in |K|
* improvement in alignment metrics
* no conflict with existing D

D versioning is strict and immutable.

---

## 8. Alignment Metrics

Q Protocol systems MUST track:

### 8.1 Expansion Success Rate (ESR)

[
\mathrm{ESR}(D) = P\big(E(C(N \mid D)\mid D) \equiv N\big)
]

---

### 8.2 Cross-Agent Plan Agreement (CPA)

Measures plan equivalence across agents under same D.

---

### 8.3 Boundary Pressure (BP)

[
\mathrm{BP} = \frac{\text{boundary emissions}}{\text{executions}}
]

**Goal:** BP → 0 for internal tasks.

---

## 9. Failure Modes

| Symptom              | Meaning                       |
| -------------------- | ----------------------------- |
| Verbose output       | Insufficient shared structure |
| Frequent boundaries  | Misplaced human coupling      |
| Missing receipts     | No real state transition      |
| Divergent expansions | D misalignment                |

---

## 10. Security and Verification

* All artifacts are signed
* Receipts are immutable
* State transitions are auditable
* Claims without RCPT are ignored

---

## 11. Design Inversion (Key Insight)

Traditional systems:

> Generate output → hope it reflects reality

Q Protocol:

> Share structure → emit only when reality requires it

---

## 12. Summary Statement

> **Q Protocol treats communication as a failure mode and coordination as the default.
> Shared understanding replaces narration.
> Silence replaces verbosity.
> Receipts replace trust.**

---

## Status

This protocol defines a **coordination substrate**, not an application.

It is suitable for:

* autonomous agent meshes
* infrastructure control
* robotics
* long-horizon systems
* human-out-of-the-loop operations
