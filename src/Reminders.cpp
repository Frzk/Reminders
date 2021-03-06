/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <QGuiApplication>
#include <QQuickView>
#include <QtQuick>

#include <sailfishapp.h>
#include "Storage.h"

#include "AvailableTagsModel.h"
#include "SortFilterModel.h"
#include "SortFilterSelectionModel.h"
#include "FoldersModel.h"
#include "ProjectsModel.h"
#include "TagsModel.h"
#include "AnnotationsModel.h"
#include "VirtualTagsModel.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setOrganizationName("org.kubler");
    app->setApplicationName("Reminders");

    QScopedPointer<QQuickView> view(SailfishApp::createView());

    Storage *storage = new Storage();
    storage->openDB();

    qmlRegisterType<QAbstractItemModel>();
    qmlRegisterType<FilterProperty>("org.kubler.Reminders", 1, 0, "FilterProperty");
    qmlRegisterType<SortProperty>("org.kubler.Reminders", 1, 0, "SortProperty");
    qmlRegisterType<SortFilterModel>("org.kubler.Reminders", 1, 0, "SortFilterModel");
    qmlRegisterType<SortFilterSelectionModel>("org.kubler.Reminders", 1, 0, "SortFilterSelectionModel");
    qmlRegisterType<FoldersModel>("org.kubler.Reminders", 1, 0, "FoldersModel");
    qmlRegisterType<ProjectsModel>("org.kubler.Reminders", 1, 0, "ProjectsModel");
    qmlRegisterType<TagsModel>("org.kubler.Reminders", 1, 0, "TagsModel");
    qmlRegisterType<AvailableTagsModel>("org.kubler.Reminders", 1, 0, "AvailableTagsModel");
    qmlRegisterType<AnnotationsModel>("org.kubler.Reminders", 1, 0, "AnnotationsModel");
    qmlRegisterType<VirtualTagsModel>("org.kubler.Reminders", 1, 0, "VirtualTagsModel");

    view->setSource(SailfishApp::pathTo("qml/Reminders.qml"));
    view->showFullScreen();

    return app->exec();
}
