﻿#Использовать logos
#Использовать tempfiles

Перем Лог;
Перем мВременныйКаталогУстановки;
Перем мЗависимостиВРаботе;

Процедура УстановитьПакетИзАрхива(Знач ФайлАрхива) Экспорт
	
	Если мЗависимостиВРаботе = Неопределено Тогда
		мЗависимостиВРаботе = Новый Соответствие;
	КонецЕсли;
	
	ПутьУстановки = НайтиСоздатьКаталогУстановки(ФайлАрхива);
	
	мВременныйКаталогУстановки = ВременныеФайлы.СоздатьКаталог();
	
	Попытка
	
		Если мЗависимостиВРаботе[ПутьУстановки.Имя] = "ВРаботе" Тогда
			ВызватьИсключение "Циклическая зависимость по пакету " + ПутьУстановки.Имя;
		КонецЕсли;
		
		мЗависимостиВРаботе.Вставить(ПутьУстановки.Имя, "ВРаботе");
	
		Лог.Отладка("Открываем архив пакета");
		ЧтениеПакета = Новый ЧтениеZipФайла;
		ЧтениеПакета.Открыть(ФайлАрхива);
		
		ФайлСодержимого = ИзвлечьОбязательныйФайл(ЧтениеПакета, Константы.ИмяФайлаСодержимогоПакета);
		ФайлМетаданных  = ИзвлечьОбязательныйФайл(ЧтениеПакета, Константы.ИмяФайлаМетаданныхПакета);
		
		Метаданные = ПрочитатьМетаданныеПакета(ФайлМетаданных);
		
		РазрешитьЗависимостиПакета(Метаданные);
		
		СтандартнаяОбработка = Истина;
		УстановитьФайлыПакета(ПутьУстановки, ФайлСодержимого, СтандартнаяОбработка);
		Если СтандартнаяОбработка Тогда
			СгенерироватьСкриптыЗапускаПриложенийПриНеобходимости(ПутьУстановки.ПолноеИмя, Метаданные);
		КонецЕсли;
		
		ЧтениеПакета.Закрыть();
		
		ВременныеФайлы.УдалитьФайл(мВременныйКаталогУстановки);
		
		мЗависимостиВРаботе.Вставить(ПутьУстановки.Имя, "Установлен");
		
	Исключение
		ЧтениеПакета.Закрыть();
		ВременныеФайлы.УдалитьФайл(мВременныйКаталогУстановки);
		ВызватьИсключение;
	КонецПопытки;
	
	Лог.Отладка("Установка завершена");
	
КонецПроцедуры

Процедура УдалитьКаталогУстановкиПриОшибке(Знач Каталог)
	Лог.Отладка("Удаляю каталог " + Каталог);
	Попытка
		УдалитьФайлы(Каталог);
	Исключение
		Лог.Отладка("Не удалось удалить каталог " + Каталог + "
		|	- " + ОписаниеОшибки());
	КонецПопытки
КонецПроцедуры

Процедура УстановитьПакетИзОблака(Знач ИмяПакета) Экспорт
	
	УстановленныеПакеты = ПолучитьУстановленныеПакеты();
	
	Если УстановленныеПакеты.ПакетУстановлен(ИмяПакета) Тогда
		Лог.Ошибка(СтрШаблон("Пакет %1 уже установлен", ИмяПакета));
	Иначе
		СкачатьИУстановитьПакет(ИмяПакета, Неопределено);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбновитьПакетИзОблака(Знач ИмяПакета) Экспорт
	
	УстановленныеПакеты = ПолучитьУстановленныеПакеты();
	
	СкачатьИУстановитьПакет(ИмяПакета, Неопределено);
	
КонецПроцедуры

Функция НайтиСоздатьКаталогУстановки(Знач ИмяПакета)
	
	СистемныеБиблиотеки = КаталогСистемныхБиблиотек();
	ФайлАрхива = Новый Файл(ИмяПакета);
	ИдентификаторПакета = ФайлАрхива.ИмяБезРасширения;
	
	ПутьУстановки = Новый Файл(ОбъединитьПути(СистемныеБиблиотеки, ИдентификаторПакета));
	Лог.Отладка("Путь установки пакета: " + ПутьУстановки.ПолноеИмя);
	
	Если Не ПутьУстановки.Существует() Тогда
		СоздатьКаталог(ПутьУстановки.ПолноеИмя);
	ИначеЕсли ПутьУстановки.ЭтоФайл() Тогда
		ВызватьИсключение "Не удалось создать каталог " + ПутьУстановки.ПолноеИмя;
	КонецЕсли;
	
	Возврат ПутьУстановки;
	
КонецФункции

Процедура РазрешитьЗависимостиПакета(Знач Манифест)
	
	Зависимости = Манифест.Зависимости();
	Если Зависимости.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	УстановленныеПакеты = ПолучитьУстановленныеПакеты();
	
	Для Каждого Зависимость Из Зависимости Цикл
		Лог.Информация("Устанавливаю зависимость: " + Зависимость.ИмяПакета);

		Если Не УстановленныеПакеты.ПакетУстановлен(Зависимость.ИмяПакета) Тогда
			// скачать
			// определить зависимости и так по кругу
			СкачатьИУстановитьПакетПоОписанию(Зависимость);
			УстановленныеПакеты.Обновить();
		Иначе
			Лог.Отладка("" + Зависимость.ИмяПакета + " установлен. Пропускаем");
			// считаем, что версия всегда подходит
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьУстановленныеПакеты()
	Возврат Новый КэшУстановленныхПакетов();
КонецФункции

Функция СерверУдаленногоХранилища()
	Возврат "http://hub.oscript.io";
КонецФункции

Процедура СкачатьИУстановитьПакетПоОписанию(Знач ОписаниеПакета)
	// TODO: Нужно скачивание конкретной версии по маркеру
	СкачатьИУстановитьПакет(ОписаниеПакета.ИмяПакета, Неопределено);
КонецПроцедуры

Процедура СкачатьИУстановитьПакет(Знач ИмяПакета, Знач ВерсияПакета)

	Если ВерсияПакета <> Неопределено Тогда
		ФайлПакета = ИмяПакета + "-" + ВерсияПакета + ".ospx";
	Иначе
		ФайлПакета = ИмяПакета + ".ospx";
	КонецЕсли;
	
	Сервер = СерверУдаленногоХранилища();
	Ресурс = "/download/" + ИмяПакета + "/" + ФайлПакета;
	Соединение = Новый HTTPСоединение(Сервер);
	
	Запрос = Новый HTTPЗапрос(Ресурс);
	Лог.Информация("Скачиваю файл: " + ФайлПакета);
	
	Ответ  = Соединение.Получить(Запрос);
	Если Ответ.КодСостояния = 200 Тогда
		ВремФайл = ОбъединитьПути(КаталогВременныхФайлов(), ФайлПакета);
		Ответ.ПолучитьТелоКакДвоичныеДанные().Записать(ВремФайл);
		Ответ.Закрыть();
		Попытка
			УстановитьПакетИзАрхива(ВремФайл);
			УдалитьФайлы(ВремФайл);
		Исключение
			УдалитьФайлы(ВремФайл);
			ВызватьИсключение;
		КонецПопытки;
	Иначе
		ТекстИсключения = СтрШаблон("Ошибка установки пакета %1 <%2>", ИмяПакета, Ответ.КодСостояния);
		Ответ.Закрыть();
		ВызватьИсключение ТекстИсключения;
	КонецЕсли;

КонецПроцедуры

Функция РазобратьМаркерВерсии(Знач МаркерВерсии)
	
	Перем ИндексВерсии;
	
	Оператор = Лев(МаркерВерсии, 1);
	Если Оператор = "<" или Оператор = ">" Тогда
		ТестОператор = Сред(МаркерВерсии, 2, 1);
		Если ТестОператор = "=" Тогда
			ИндексВерсии = 3;
		Иначе
			ИндексВерсии = 2;
		КонецЕсли;
	ИначеЕсли Оператор = "=" Тогда
		ИндексВерсии = 2;
	ИначеЕсли Найти("0123456789", Оператор) > 0 Тогда
		ИндексВерсии = 1;
	Иначе
		ВызватьИсключение "Некорректно задан маркер версии";
	КонецЕсли;
	
	Если ИндексВерсии > 1 Тогда
		Оператор = Лев(МаркерВерсии, ИндексВерсии-1);
	Иначе
		Оператор = "";
	КонецЕсли;
	
	Версия = Сред(МаркерВерсии, ИндексВерсии);
	
	Возврат Новый Структура("Оператор,Версия", Оператор, Версия);
	
КонецФункции

Функция КаталогСистемныхБиблиотек()
	
	СистемныеБиблиотеки = ОбъединитьПути(КаталогПрограммы(), ПолучитьЗначениеСистемнойНастройки("lib.system"));
	Лог.Отладка("СистемныеБиблиотеки " + СистемныеБиблиотеки);
	Если СистемныеБиблиотеки = Неопределено Тогда
		ВызватьИсключение "Не определен каталог системных библиотек";
	КонецЕсли;
	
	Возврат СистемныеБиблиотеки;
	
КонецФункции

Процедура УстановитьФайлыПакета(Знач ПутьУстановки, Знач ФайлСодержимого, СтандартнаяОбработка)
	
	ЧтениеСодержимого = Новый ЧтениеZipФайла(ФайлСодержимого);
	Попытка	
		ИмяСкриптаУстановки = Константы.ИмяФайлаСкриптаУстановки;
		ЭлементСкриптаУстановки = ЧтениеСодержимого.Элементы.Найти(ИмяСкриптаУстановки);
		Если ЭлементСкриптаУстановки <> Неопределено Тогда
			Лог.Отладка("Найден скрипт установки пакета");
			
			ЧтениеСодержимого.Извлечь(ЭлементСкриптаУстановки, мВременныйКаталогУстановки, РежимВосстановленияПутейФайловZIP.НеВосстанавливать);
			Лог.Отладка("Компиляция скрипта установки пакета");
			ОбъектСкрипта = ЗагрузитьСценарий(ОбъединитьПути(мВременныйКаталогУстановки, ИмяСкриптаУстановки));
			
			ВызватьСобытиеПередУстановкой(ОбъектСкрипта, ЧтениеСодержимого, ПутьУстановки.ПолноеИмя, СтандартнаяОбработка);
			
			Если СтандартнаяОбработка Тогда
				
				Лог.Отладка("Устанавливаю файлы пакета из архива");
				ЧтениеСодержимого.ИзвлечьВсе(ПутьУстановки.ПолноеИмя);
				
				ВызватьСобытиеПриУстановке(ОбъектСкрипта, ПутьУстановки.ПолноеИмя, СтандартнаяОбработка);
				
			КонецЕсли;
		Иначе
			Лог.Отладка("Устанавливаю файлы пакета из архива");
			ЧтениеСодержимого.ИзвлечьВсе(ПутьУстановки.ПолноеИмя);
		КонецЕсли;
	Исключение
		ЧтениеСодержимого.Закрыть();
		ВызватьИсключение;
	КонецПопытки;
	
	ЧтениеСодержимого.Закрыть();
	
КонецПроцедуры

Процедура ВызватьСобытиеПередУстановкой(Знач ОбъектСкрипта, Знач АрхивПакета, Знач Каталог, СтандартнаяОбработка)
	Лог.Отладка("Вызываю событие ПередУстановкой");
	ОбъектСкрипта.ПередУстановкой(АрхивПакета, Каталог, СтандартнаяОбработка);
КонецПроцедуры

Процедура ВызватьСобытиеПриУстановке(Знач ОбъектСкрипта, Знач Каталог, СтандартнаяОбработка)
	Лог.Отладка("Вызываю событие ПриУстановке");
	ОбъектСкрипта.ПриУстановке(Каталог, СтандартнаяОбработка);
КонецПроцедуры

Процедура СгенерироватьСкриптыЗапускаПриложенийПриНеобходимости(Знач КаталогУстановки, Знач ОписаниеПакета)
	
	ИмяПакета = ОписаниеПакета.Свойства().Имя;
	
	Для Каждого ФайлПриложения Из ОписаниеПакета.ИсполняемыеФайлы() Цикл
	
		Лог.Отладка("Регистрация приложения: " + ФайлПриложения);
		
		ОбъектФайл = Новый Файл(ОбъединитьПути(КаталогУстановки, ФайлПриложения));
		
		Если Не ОбъектФайл.Существует() Тогда
			Лог.Ошибка("Файл приложения " + ОбъектФайл.ПолноеИмя + " не существует");
			ВызватьИсключение "Некорректные данные в метаданных пакета";
		КонецЕсли;

		Каталог = КаталогПрограммы();
		СИ = Новый СистемнаяИнформация();
		Если Найти(СИ.ВерсияОС, "Windows") > 0 Тогда
			ФайлЗапуска = Новый ЗаписьТекста(ОбъединитьПути(Каталог, ИмяПакета + ".bat"), "cp866");
			ФайлЗапуска.ЗаписатьСтроку("@echo off");
			ФайлЗапуска.ЗаписатьСтроку("oscript.exe """ + ОбъектФайл.ПолноеИмя + """ %*");
			ФайлЗапуска.Закрыть();
		Иначе
			// TODO: проверить
			ФайлЗапуска = Новый ЗаписьТекста(ОбъединитьПути(Каталог, ИмяПакета));
			ФайлЗапуска.ЗаписатьСтроку("#!/bin/bash");
			ФайлЗапуска.ЗаписатьСтроку("/usr/bin/oscript """ + ОбъектФайл.ПолноеИмя + " $@""");
			ФайлЗапуска.Закрыть();
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПрочитатьМетаданныеПакета(Знач ФайлМетаданных)
	
	Перем Метаданные;
	
	Попытка
		Чтение = Новый ЧтениеXML;
		Чтение.ОткрытьФайл(ФайлМетаданных);
		
		Сериализатор = Новый СериализацияМетаданныхПакета;
		Метаданные = Сериализатор.ПрочитатьXML(Чтение);
		
		Чтение.Закрыть();
	Исключение
		Чтение.Закрыть();
		ВызватьИсключение;
	КонецПопытки;
	
	Возврат Метаданные;
	
КонецФункции

//////////////////////////////////////////////////////////////////////////////////
//

Функция ИзвлечьОбязательныйФайл(Знач Чтение, Знач ИмяФайла)
	Элемент = Чтение.Элементы.Найти(ИмяФайла);
	Если Элемент = Неопределено Тогда
		ВызватьИсключение "Неверная структура пакета. Не найден файл " + ИмяФайла;
	КонецЕсли;
	
	Чтение.Извлечь(Элемент, мВременныйКаталогУстановки);
	
	Возврат ОбъединитьПути(мВременныйКаталогУстановки, ИмяФайла);
	
КонецФункции

Лог = Логирование.ПолучитьЛог("oscript.app.opm");