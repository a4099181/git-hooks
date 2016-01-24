install:
	test -d build\~ && \
	    cp build\~/* ../.git/hooks/ && \
	    find ../.git/hooks -not -name '*.sample' -type f -exec chmod u+x '{}' \; \
	    || exit 0

uninstall:
	find ../.git/hooks -not -name '*.sample' -type f -delete

clean:
	git clean -dxf -- .

configure:
	bash configure.bash

reinstall: uninstall install
