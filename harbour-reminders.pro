# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-reminders

CONFIG += sailfishapp

QT += sql

HEADERS += \
    src/ProjectsModel.h \
    src/Storage.h

SOURCES += \
    src/Reminders.cpp \
    src/ProjectsModel.cpp \
    src/Storage.cpp

OTHER_FILES += \
    qml/Reminders.qml \
    qml/models/FoldersModel.qml \
    qml/cover/CoverPage.qml \
    qml/components/FolderDelegate.qml \
    qml/pages/Folders.qml \
    rpm/$${TARGET}.changes.in \
    rpm/$${TARGET}.spec \
    rpm/$${TARGET}.yaml \
    $${TARGET}.desktop


# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
#TRANSLATIONS += translations/harbour-reminders-de.ts
