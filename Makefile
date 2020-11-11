.PHONY: clean

example/custom-section.wasm: example/custom-section.wat
	wat2wasm -o $@ $< --debug-names

example/%.wasm: example/%.wat
	wat2wasm -o $@ $<

clean:
	rm -f example/*.wasm
