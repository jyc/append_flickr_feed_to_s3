IN_DIR=src/examples
OUT_DIR=examples

OUT=$(addprefix $(OUT_DIR)/,crud.jsx.txt store.jsx.txt)

.PHONY: all examples npm-build clean

all: npm-build public/ACKNOWLEDGMENTS.txt

examples: $(OUT)

npm-build: examples
	npm run build

clean:
	rm -f $(OUT)
	rm -rf build
	rm -rf node_modules
	rm -rf netlify

netlify: npm-build public/ACKNOWLEDGMENTS.txt
	# Allowlisted; don't copy e.g. .map files.
	mkdir -p netlify
	cp -R public/eot netlify/
	cp -R public/ttf netlify/
	cp -R public/woff netlify/
	cp -R public/woff2 netlify/
	cp build/agent.js netlify/
	cp build/index.js netlify/
	cp public/baseStyle.css netlify/
	cp public/favicon.ico netlify/
	cp public/index.html netlify/
	cp public/sandboxStyle.css netlify/
	cp public/ACKNOWLEDGMENTS.txt netlify/

$(OUT_DIR)/%.jsx.txt: $(IN_DIR)/%.tsx
	npx detype $< $@

public/ACKNOWLEDGMENTS.txt: misc/ACKNOWLEDGMENTS.template.txt package.json
	cat misc/ACKNOWLEDGMENTS.template.txt > $@
	npx generate-license-file --input package.json --overwrite --output $@.tmp
	cat $@.tmp >> $@
	rm $@.tmp
