# Cargo Cult Project Notes

## 1. Project Goals
- **Simplify X16 Programming**: Create a domain-specific language (DSL) tailored for the Commander X16 platform.
- **Learn from C and Pascal**: Avoid pitfalls of those languages while retaining their strengths.
- **Enhance Productivity**: Enable easier development of complex programs like X16 Terrarium.
- **Prioritize Flattening**: Keep the generated code efficient and compatible with the constraints of the X16.

---

## 2. Syntax Decisions
### General Syntax Rules
- **Cargo Blocks**: Namespaces start with a cargo declaration, e.g., `cargo biochem { ... }`.
  - Example:
    ```
    cargo biochem {
       var drives: array[10] of uint8;
    }
    ```
  - Translates to:
    ```
    biochem_drives[0] = random(256);
    ```
- **Unique Cargo Names**: Cargo names must be globally unique to avoid collisions.
- **Flow Control**: No parentheses around conditions.
  - Example: `if x == 5 { ... }` instead of `if (x == 5) { ... }`.

### Flattening Namespaces
- Flatten namespace components into single identifiers.
  - Example: `biochem.drives[0]` becomes `biochem_drives[0]`.
- Simple and deterministic naming prevents collisions and ensures efficient transpilation.

---

## 3. Core Features
### Structures and Bitfields
- Support structures and bitfields for efficient memory use and organization.
  - Example:
    ```
    cargo game {
       struct player {
          health: uint8;
          position: uint16;
       };
    }
    ```
  - Translates to straightforward memory layouts in transpiled code.

### Arrays and Types
- Support arrays with static bounds.
- Strong, explicitly defined types (e.g., `uint8`, `array[10] of uint8`).

### Simple Functions
- Allow function definitions within cargos.
  - Example:
    ```
    cargo math {
       fn square(x: uint8): uint8 {
          return x * x;
       }
    }
    ```

### Randomness
- Provide utilities like `random()` for simple use.

---

## 4. Implementation Details
### Transpilation Target
- **Prog8**: Target Prog8 as the initial output language due to its focus on 8-bit systems.
- Flattened namespace and syntax rules align with Prog8 for straightforward transpilation.

### Grammar and Parsing
- **Cargo Grammar**: Use Raku grammars and actions to parse the DSL.
- Flatten namespaces during the action phase.

### Error Handling
- Validate unique cargo names during parsing to prevent collisions.
- Provide clear syntax error messages for easier debugging.

---

## 5. Open Questions
- **Enhanced Syntax Features**: Are there additional "nice-to-have" features that could be included without complicating the language?
- **Testing Framework**: Should a lightweight test framework be built into the language or provided externally?
- **Optimization**: How much optimization should transpilation perform for X16 constraints?
- **Long-Term Targets**: Should we eventually support other 8-bit platforms, or remain focused solely on the X16?

---

## Next Steps
1. Write Raku grammar for the Cargo Cult language.
2. Implement actions to handle namespace flattening and transpilation.
3. Test basic features: cargo namespaces, structures, arrays, and simple functions.
4. Refine syntax and implementation based on early feedback and testing.

---

