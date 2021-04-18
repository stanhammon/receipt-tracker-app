#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QFile>
#include <QTextStream>

class FileIO : public QObject
{
    Q_OBJECT

public slots:
    QString read(const QString& path)
    {
        if (path.isEmpty())
            return "";

        QFile file(path);
        if (!file.open(QFile::ReadOnly))
            return "";

        QString text = file.readAll();
        return text;
    }

    bool write(const QString& path, const QString& data)
    {
        if (path.isEmpty())
            return false;

        QFile file(path);
        if (!file.open(QFile::WriteOnly | QFile::Truncate))
            return false;

        QTextStream out(&file);
        out << data;
        file.close();
        return true;
    }

public:
    FileIO() {}
};

#endif // FILEIO_H
