# Библиотека полезных скриптов для 1Script

Все пакеты библиотеки могут быть подключены с помощью директивы **#Использовать <ИмяПакета>**

## Краткий список и назначение пакетов

###asserts

Добавляет в скрипт функционал "Утверждений" (assertions). Возможны 2 стиля использования:

* Модуль "Утверждения" - утверждения в стиле фреймворка xUnitFor1C
* Свойство глобального контекста "Ожидаем" - fluent-API утверждений в стиле BDD

###cmdline

Библиотека разбора аргументов командной строки. Добавляет класс "ПарсерАргументовКоманднойСтроки", позволяющий удобным образом обрабатывать параметры запуска скрипта.

###json

Порт модуля 1С:JSON Александра Переверзева с сайта infostart.ru

###logos

Библиотека логирования в стиле log4j

###v8runner

Удобная оболочка для запуска команд конфигуратора. Позволяет удобно запускать любые команды пакетного режима Конфигуратора и 1С:Предприятия.

###tempfiles

Менеджер управления временными файлами и каталогами

###tool1cd

Программная скриптовая обертка для популярной утилиты чтения файловых баз данных tool1cd от [awa](http://infostart.ru/profile/13819/) Удобно использовать, например, для работы с хранилищем 1С.
