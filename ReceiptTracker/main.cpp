#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "FileIO.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    FileIO fileIO;

    QGuiApplication app(argc, argv);
    app.setOrganizationName("Stan Hammon Software");
    app.setOrganizationDomain("www.stanhammonsoftware.com");
    app.setApplicationName("Receipt Tracker");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("fileio", &fileIO);
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
