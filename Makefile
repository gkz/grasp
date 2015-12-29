default: all

LS_SRC = $(shell find assets/_ls -name "*.ls" -type f | sort)
JS = $(LS_SRC:assets/_ls/%.ls=assets/js/%.js)

SASS = $(shell find assets/_sass -name "*.sass" -type f | sort)
CSS = $(SASS:assets/_sass/%.sass=assets/css/%.css)

LS = node_modules/livescript
LSC = node_modules/.bin/lsc

BROWSERIFY = node_modules/.bin/browserify


package.json: package.json.ls
	$(LSC) --compile package.json.ls

assets/js/%.js: assets/_ls/%.ls
	$(LSC) --compile --output assets/js "$<"

assets/js/demo-all.js: node_modules/grasp/lib $(JS)
	$(BROWSERIFY) --no-detect-globals assets/js/demo.js > assets/js/demo-all.js

assets/css:
	mkdir -p assets/css

assets/css/%.css: assets/_sass/%.sass assets/css
	sass "$<":"$@"

docs/options.html: scripts/generate-options.ls node_modules/grasp/lib/options.js
	$(LSC) scripts/generate-options.ls > docs/options.html

docs/syntax-js.html: scripts/generate-syntax-js.ls node_modules/grasp-syntax-javascript/index.js
	$(LSC) scripts/generate-syntax-js.ls > docs/syntax-js.html

.PHONY: all real-all build watch serve install clean

all: real-all
	@true

real-all: build

build: $(JS) assets/js/demo-all.js $(CSS) package.json docs/options.html docs/syntax-js.html

watch:
	tjwatch -i 500ms make --no-print-directory

serve:
	bundle exec jekyll serve --watch

install: package.json
	npm install .
	bundle install

clean:
	rm package.json
