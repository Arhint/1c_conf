﻿
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	// Вставити вміст обробника.
	
	Движения.ПартииТоваров.Записывать = истина;
	Движения.ТоварыНаСкладе.Записывать = истина;
	Движения.ТоварыНаСкладе.Очистить();
	Движения.ПартииТоваров.Очистить(); // Очищаем данные в регистре связанные с этим документом для защиты от дублирования при перепроведениии
	Движения.ПартииТоваров.Записать();
	Движения.ТоварыНаСкладе.Записать();
	
	
	ТаблицаПартий = Движения.ПартииТоваров.Выгрузить();
	ТаблицаТоварыНаСкладе = Движения.ТоварыНаСкладе.Выгрузить();
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ПеремещениеТоваровТовары.Номенклатура КАК Номенклатура,
	               |	ПеремещениеТоваровТовары.Количество КАК Количество,
	               |	ПеремещениеТоваровТовары.Ссылка.СкладОтправитель КАК СкладОтправитель,
	               |	ПеремещениеТоваровТовары.Ссылка.СкладПолучатель КАК СкладПолучатель,
	               |	ПартииТоваровОстатки.Партия КАК Партия,
	               |	ЕСТЬNULL(ПартииТоваровОстатки.КоличествоОстаток, 0) КАК ПартииТоваровОстатки,
	               |	ПартииТоваровОстатки.СуммаОстаток КАК СуммаОстаток
	               |ИЗ
	               |	Документ.ПеремещениеТоваров.Товары КАК ПеремещениеТоваровТовары
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ПартииТоваров.Остатки(&Дата, ) КАК ПартииТоваровОстатки
	               |		ПО ПеремещениеТоваровТовары.Ссылка.СкладОтправитель = ПартииТоваровОстатки.Склад
	               |			И ПеремещениеТоваровТовары.Номенклатура = ПартииТоваровОстатки.Номенклатура
	               |ГДЕ
	               |	ПеремещениеТоваровТовары.Ссылка = &Ссылка
	               |ИТОГИ
	               |	МИНИМУМ(Количество),
	               |	СУММА(ПартииТоваровОстатки),
	               |	СУММА(СуммаОстаток)
	               |ПО
	               |	Номенклатура";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Дата", Дата);
	//Запрос.УстановитьПараметр("ВидДвижения",ВидДвиженияНакопления.Расход);
	
	ВыборкаПоТоварам = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаПоТоварам.Следующий() цикл
		//Если ВыборкаПоТоварам.Количество > ВыборкаПоТоварам.КоличествоОстаток тогда
		Если ВыборкаПоТоварам.Количество > ВыборкаПоТоварам.ПартииТоваровОстатки тогда
			Мес = новый СообщениеПользователю;
			Мес.Текст = "Недостаточно товара "+Строка(ВыборкаПоТоварам.Номенклатура);
			Мес.Сообщить();
			отказ = истина;
			
		Иначе
			Если не отказ тогда
			НаСписание = ВыборкаПоТоварам.Количество;
			ВыборкаПопартиям = ВыборкаПоТоварам.Выбрать(ОбходРезультатаЗапроса.Прямой);
			Пока ВыборкаПоПартиям.Следующий() цикл
				КСписанию = Мин(НаСписание, ВыборкаПоТоварам.ПартииТоваровОстатки);
				Если КСписанию = ВыборкаПоПартиям.ПартииТоваровОстатки тогда
					СуммаСписания = ВыборкаПоПартиям.СуммаОстаток;
				Иначе 
					СуммаСписания = (ВыборкаПоПартиям.СуммаОстаток / ВыборкаПоПартиям.ПартииТоваровОстатки) * КСписанию;
				КонецЕсли;
				ДвижСписание = ТаблицаПартий.Добавить();
						// расход партий
				ЗаполнитьЗначенияСвойств(ДвижСписание, ВыборкаПоПартиям); // Заполняем значениями
				ДвижСписание.Период = Дата;
				ДвижСписание.Активность = Истина;
				ДвижСписание.Количество = КСписанию;
				ДвижСписание.Сумма = СуммаСписания;
				ДвижСписание.Склад = ВыборкаПоПартиям.СкладОтправитель;
				НаСписание = НаСписание - КСписанию;
				ДвижСписание.ВидДвижения = ВидДвиженияНакопления.Расход;
				       // приход партий
				ДвижПолучение = ТаблицаПартий.Добавить();
				ЗаполнитьЗначенияСвойств(ДвижПолучение, ВыборкаПоПартиям); // Заполняем значениями
				ДвижПолучение.Период = Дата;
				ДвижПолучение.Активность = Истина;
				ДвижПолучение.Количество = КСписанию;
				ДвижПолучение.Сумма = СуммаСписания;
				ДвижПолучение.Склад = ВыборкаПоПартиям.СкладПолучатель;
				ДвижПолучение.ВидДвижения = ВидДвиженияНакопления.Приход;
				       // списание со склада
				ДвижСкладСписание = ТаблицаТоварыНаСкладе.Добавить();
				ЗаполнитьЗначенияСвойств(ДвижСкладСписание, ВыборкаПоТоварам);
				ДвижСкладСписание.Период = Дата;
				ДвижСкладСписание.Активность = Истина;
				ДвижСкладСписание.Склад = СкладОтправитель;
				ДвижСкладСписание.ВидДвижения = ВидДвиженияНакопления.Расход;
				        // поступление на склада
				ДвижСкладПоступление = ТаблицаТоварыНаСкладе.Добавить();
				ЗаполнитьЗначенияСвойств(ДвижСкладПоступление, ВыборкаПоТоварам);
				ДвижСкладПоступление.Период = Дата;
				ДвижСкладПоступление.Активность = Истина;
				ДвижСкладПоступление.Склад = СкладПолучатель;
				ДвижСкладПоступление.ВидДвижения = ВидДвиженияНакопления.Приход;


				Если НаСписание = 0 тогда // Когда кол-во на списание станет равно нулю прерываем цикл.
					Прервать;
				КонецЕсли;
	

			Конеццикла;
			конецесли;
		Конецесли;
		
	Конеццикла;
	
	Если не отказ тогда
		//ТаблицаПартий.ЗаполнитьЗначения(ВидДвиженияНакопления.Расход, "ВидДвижения"); // Заполняем параметр "Вид движения"
		Движения.ПартииТоваров.Загрузить(ТаблицаПартий); // Записываем данные в регистр
		Движения.ТоварыНаСкладе.Загрузить(ТаблицаТоварыНаСкладе);
	КонецЕсли;
	
	//ТаблицаДляТоваровНаСкладах = ТаблицаДляПроведения.Скопировать(,"ВидДвижения, Период, Склад, Номенклатура, Количество");
	
	//Движения.ТоварыНаСкладе.Записывать = Истина;
	//
	//Движения.ТоварыНаСкладе.Загрузить(ТаблицаДляТоваровНаСкладах);
	
КонецПроцедуры
