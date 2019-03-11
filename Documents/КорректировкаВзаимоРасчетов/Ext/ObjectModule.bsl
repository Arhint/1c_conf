﻿
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	// Вставити вміст обробника.
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВзаиморасчетыОстаткиИОбороты.Контрагент КАК Контрагент,
	               |	СУММА(ЕСТЬNULL(ВзаиморасчетыОстаткиИОбороты.СуммаПриход, 0)) КАК СуммаПриход,
	               |	СУММА(ЕСТЬNULL(ВзаиморасчетыОстаткиИОбороты.СуммаРасход, 0)) КАК СуммаРасход
	               |ИЗ
	               |	РегистрНакопления.Взаиморасчеты.ОстаткиИОбороты КАК ВзаиморасчетыОстаткиИОбороты
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВзаиморасчетыОстаткиИОбороты.Контрагент";
	
	Движения.Взаиморасчеты.Очистить();
	Движения.Взаиморасчеты.Записать();
	Движения.Взаиморасчеты.Записывать = Истина;
	
	ТЗ = Запрос.Выполнить().Выгрузить();
	
	Для каждого стр из ТЗ цикл
		
		Если стр.Контрагент = Отправитель тогда
			ДоступнаяСуммаСписания = стр.СуммаПриход - стр.СуммаРасход;
			Если ДоступнаяСуммаСписания >= 0 тогда
				Сообщить("Отправитель нам ничего не должен!");
				отказ = истина;
				Возврат;
			КонецЕсли;
		Иначе
			МаксимальнаяСуммаКСписанию = стр.СуммаПриход - стр.СуммаРасход;
			Если МаксимальнаяСуммаКСписанию <= 0 тогда
				Сообщить("Мы ничего не должны получателю!");
				отказ = истина;
				Возврат;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если (Сумма + ДоступнаяСуммаСписания) > 0 тогда
		Сообщить("Сумма списания превышает долг отправителя перед нами!");
		отказ = истина;
		Возврат;
	ИначеЕсли Сумма > МаксимальнаяСуммаКСписанию тогда
		Сообщить("Сумма больше нашего долга перед получателем!");
		отказ = истина;
		Возврат;
	Иначе
		ТаблицаКор = Движения.Взаиморасчеты.Выгрузить();
	
		ДвижОтпр = ТаблицаКор.Добавить();
		
		ДвижОтпр.Период = Дата;
		ДвижОтпр.Активность = Истина;
		ДвижОтпр.ВидДвижения = ВидДвиженияНакопления.Приход;
		ДвижОтпр.Контрагент = Отправитель; 
		ДвижОтпр.Сумма = Сумма;
		
		ДвижПолуч = ТаблицаКор.Добавить();
		ДвижПолуч.Период = Дата;
		ДвижПолуч.Активность = Истина;
		ДвижПолуч.ВидДвижения = ВидДвиженияНакопления.Расход;
		ДвижПолуч.Контрагент = Получатель; 
		ДвижПолуч.Сумма = Сумма;

		Движения.Взаиморасчеты.Загрузить(ТаблицаКор);
			
	КонецЕсли;
	
КонецПроцедуры
