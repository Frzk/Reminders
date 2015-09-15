#ifndef TAGSSELECTIONMODEL_H
#define TAGSSELECTIONMODEL_H

#include <QSqlTableModel>

class TagsSelectionModel : public QSqlTableModel
{
    Q_OBJECT

    public:
        explicit TagsSelectionModel(QObject *parent = 0);
        ~TagsSelectionModel();

        // QSqlTableModel :
        QVariant                data(const QModelIndex &index, int role = Qt::DisplayRole) const;
        QHash<int, QByteArray>  roleNames() const;

        // QML API :
        //Q_INVOKABLE void          setSelected(const TagsModel & selection);
        //Q_INVOKABLE void          createMissingTags();
};

#endif // TAGSSELECTIONMODEL_H
