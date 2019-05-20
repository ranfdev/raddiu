project('com.github.ranfdev.raddiu', 'vala', 'c', version: '0.1.0')

i18n = import('i18n')

gnome = import ('gnome')

add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()),
    language:'c'
)

asresources = gnome.compile_resources(
  'as-resources',
  join_paths('data', 'com.github.ranfdev.raddiu' + '.gresource.xml'),
  source_dir: 'data',
  c_name: 'as'
)

config_data = configuration_data()
config_data.set('EXEC_NAME', meson.project_name())

conf_data = configuration_data()
conf_data.set_quoted('PROJECT_NAME', meson.project_name())
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf_data.set_quoted('VERSION', meson.project_version())
conf_data.set_quoted('PREFIX', get_option('prefix'))

code_files = files(
    'src/Application.vala',
    'src/Services/Api.vala',
    'src/Widgets/WebImage.vala',
    'src/Widgets/Radio.vala',
    'src/Widgets/RadioList.vala',
    'src/Widgets/PlayingPanel.vala',
    'src/Views/Discover.vala',
    'src/Views/Search.vala',
    'src/Views/Recents.vala'
)

dependencies = [
    dependency('gio-unix-2.0', version: '>=2.20'),
    dependency('granite'),
    dependency('json-glib-1.0'),
    dependency('libsoup-2.4'),
    dependency('gdk-pixbuf-2.0'),
]

executable(
    meson.project_name(),
    code_files,
    asresources,
    dependencies: dependencies,
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
