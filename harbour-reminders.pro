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

CONFIG += sailfishapp \
    sailfishapp_i18n \
    c++11

QT += sql

HEADERS += \
    src/FoldersModel.h \
    src/Storage.h

SOURCES += src/Reminders.cpp \
    src/FoldersModel.cpp \
    src/Storage.cpp

OTHER_FILES += \
    qml/Reminders.qml \
    qml/cover/CoverPage.qml \
    qml/components/FolderDelegate.qml \
    qml/pages/Folders.qml \
    rpm/$${TARGET}.changes.in \
    rpm/$${TARGET}.spec \
    rpm/$${TARGET}.yaml \
    $${TARGET}.desktop

#TRANSLATIONS += translations/harbour-reminders-de.ts
