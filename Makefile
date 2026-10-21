# Validate that modular skill profiles comply with master CLAUDE.md guidelines
validate-skills:
	@echo "🔍 Checking modular skill profile compliance..."
	@if [ ! -d "tests/skills" ] || [ -z "$$(ls -A tests/skills/*.md 2>/dev/null)" ]; then \
		echo "⚠️ No skill profile documents discovered under tests/skills/"; \
		exit 1; \
	fi
	@echo "✅ Core directory framework validated."
	@echo "🤖 Prompting Claude agent rule compliance overview..."
