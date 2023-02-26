project('libexpidus', 'c', license: 'GPL-3.0-only', version: '0.1.0-prealpha', default_options: [
  'default_library=both'
])

pkg = import('pkgconfig')
gnome = import('gnome')

prefix = get_option('prefix')
bindir = prefix / get_option('bindir')
datadir = prefix / get_option('datadir')
libdir = prefix / get_option('libdir')
libexecdir = prefix / get_option('libexecdir')
includedir = prefix / get_option('includedir')
localstatedir = get_option('localstatedir')
sysconfdir = get_option('sysconfdir')

longver = '@0@'.format(meson.project_version())
shortver = longver
git = find_program('git', native: true, required: false)
conf_data = configuration_data()
build_user = get_option('build-user')

if git.found()
  git_commit = run_command(git, 'rev-parse', '--short', 'HEAD', check: false)
  git_branch = run_command(git, 'rev-parse', '--abbrev-ref', 'HEAD', check: false)
  git_config_username = run_command(git, 'config', '--get', 'user.name', check: false)
  git_config_email = run_command(git, 'config', '--get', 'user.email', check: false)

  if git_commit.returncode() == 0
    git_commit = git_commit.stdout().strip()
  else
    git_commit = get_option('git-commit')
  endif

  if git_branch.returncode() == 0
    git_branch = git_branch.stdout().strip()
  else
    git_branch = get_option('git-branch')
  endif

  if git_config_username.returncode() == 0 and git_config_email.returncode() == 0
    git_config_username = git_config_username.stdout().strip()
    git_config_email = git_config_email.stdout().strip()
    build_user = '@0@ (@1@)'.format(git_config_username, git_config_email)
  endif
else
  git_commit = get_option('git-commit')
  git_branch = get_option('git-branch')
endif

shortver = '@0@-@1@'.format(meson.project_version(), git_commit)
longver = '@0@ (branch \'@1@\')'.format(shortver, git_branch)
version = shortver.split('-')[0]

if get_option('buildtype') == 'release'
  shortver = meson.project_version()
endif

conf_data.set('BUILD_USER', build_user)

conf_data.set('GIT_COMMIT', git_commit)
conf_data.set('GIT_BRANCH', git_branch)

conf_data.set('VERSION', version)
conf_data.set('VERSION_LONG', longver)
conf_data.set('VERSION_SHORT', shortver)

conf_data.set('LOCALSTATEDIR', localstatedir)
conf_data.set('SYSCONFDIR', sysconfdir)

add_global_arguments([
  '-Werror=unused-variable'
], language: 'c')

tests = get_option('tests').disable_auto_if(not dependency('check', native: true, required: false).found())
docs = get_option('docs').disable_auto_if(not dependency('gtk-doc', native: true, required: false).found())

check = dependency('check', required: tests, native: true)
gtkdoc = dependency('gtk-doc', native: true, required: docs)

neutron = dependency('neutron-elemental', required: true)

build_conf = configure_file(input: 'src/build.h.in', output: 'libexpidus-build.h',
  configuration: conf_data)

libexpidus_sources = ['src/config/parser.c']
libexpidus_deps = [neutron]
libexpidus_cflags = []
libexpidus_inc = include_directories('include')

libexpidus = library('expidus', libexpidus_sources,
  c_args: libexpidus_cflags,
  include_directories: libexpidus_inc,
  dependencies: libexpidus_deps,
  version: version,
  gnu_symbol_visibility: 'hidden',
  install: true)
venfig = declare_dependency(link_with: libexpidus,
  dependencies: libexpidus_deps,
  include_directories: libexpidus_inc)

pkg.generate(libexpidus,
  name: 'libexpidus',
  description: 'Library for handling a lot of the ExpidusOS specific functionality',
  url: 'https://github.com/ExpidusOS/libexpidus',
  version: shortver,
  requires: libexpidus_deps)

install_subdir('include', strip_directory: true,
  install_dir: includedir)

subdir('tests', if_found: [check])
subdir('docs', if_found: [gtkdoc])

summary({
  'Built by': build_user,
  'Version': version,
  'Version (long)': longver,
  'Version (short)': shortver
}, section: 'libexpidus')
