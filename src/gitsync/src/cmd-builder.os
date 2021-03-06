﻿//////////////////////////////////////////////////////////////////////////
// Работа с командными файлами

#Использовать tempfiles

Перем мЗаписьТекста;
Перем мПуть;

Функция Открыть(Знач Путь = "") Экспорт
	
	Если ПустаяСтрока(Путь) Тогда
		мПуть = ВременныеФайлы.НовоеИмяФайла(".bat");
	Иначе
		мПуть = Путь;
	КонецЕсли;
	
	мЗаписьТекста = Новый ЗаписьТекста(мПуть, "cp866");
	
	Возврат мПуть;
	
КонецФункции

Процедура Добавить(Знач Команда) Экспорт
	ПроверитьЧтоФайлОткрыт();
	мЗаписьТекста.ЗаписатьСтроку(Команда);
КонецПроцедуры

Функция Выполнить() Экспорт
	
	Закрыть();
	
	ПутьПакетногоФайла = мПуть;
	
	СтрокаЗапуска = "cmd.exe /C """ + ПутьПакетногоФайла + """";
	
	КодВозврата = "";
	ЗапуститьПриложение(СтрокаЗапуска,, Истина, КодВозврата);
	
	Возврат КодВозврата;

КонецФункции

Функция Закрыть() Экспорт
	
	Если мЗаписьТекста <> Неопределено Тогда
		мЗаписьТекста.Закрыть();
		мЗаписьТекста = Неопределено;
	КонецЕсли;
	
	Возврат мПуть;
	
КонецФункции

Процедура ПроверитьЧтоФайлОткрыт()
	Если мЗаписьТекста = Неопределено Тогда
		Открыть();
	КонецЕсли;
КонецПроцедуры
