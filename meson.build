project('com.github.artemanufrij.findfileconflicts', ['vala', 'c'],
        version: '1.0.0')

i18n = import('i18n')
gnome = import('gnome')

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

c_args = [
  '-include', 'config.h'
]

deps = [
  dependency('granite'),
  dependency('gtk+-3.0'),
  meson.get_compiler('vala').find_library('posix')
]

#asresources = gnome.compile_resources(
#    'as-resources', 'schemas/' + meson.project_name() + '.gresource.xml',
#    source_dir: 'schemas',
#    c_name: 'as'
#)

executable(
    meson.project_name(),
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/Settings.vala',
    'src/Objects/LocalFile.vala',
    'src/Services/LocalFilesManager.vala',
    'src/Services/LibraryManager.vala',
    'src/Dialogs/Preferences.vala',
    'src/Widgets/LocalFile.vala',
    'src/Widgets/FilesConflict.vala',
    'src/Widgets/IllegalFile.vala',
    'src/Widgets/Views/Conflicts.vala',
    'src/Widgets/Views/Welcome.vala',
    'src/Utils/Utils.vala',

 #   asresources,
    c_args: c_args,
    dependencies: [
        deps
    ],
    install : true
)

meson.add_install_script('meson/post_install.py')

subdir('schemas')
subdir('data')
#subdir('po')
