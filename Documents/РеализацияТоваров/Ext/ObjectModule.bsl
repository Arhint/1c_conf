﻿Перем КурсУпр;

Функция ПолучитьДанные()
	
	Запрос = новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	РеализацияТоваровТовары.Номенклатура КАК Номенклатура,
	               |	РеализацияТоваровТовары.Цена КАК Цена,
	               |	РеализацияТоваровТовары.Количество КАК Количество,
	               |	РеализацияТоваровТовары.Сумма КАК Сумма,
	               |	РеализацияТоваровТовары.Ссылка.Дата КАК Период,
	               |	РеализацияТоваровТовары.Ссылка.Контрагент КАК Контрагент,
	               |	РеализацияТоваровТовары.Ссылка.Склад КАК Склад,
	               |	&ВидДвижения КАК ВидДвижения,
	               |	РеализацияТоваровТовары.Ссылка.СуммаДокумента КАК СуммаДокумента,
	               |	РеализацияТоваровТовары.Ссылка КАК Партия
	               |ИЗ
	               |	Документ.РеализацияТоваров.Товары КАК РеализацияТоваровТовары
	               |ГДЕ
	               |	РеализацияТоваровТовары.Ссылка = &ссылка";
	Запрос.УстановитьПараметр("Ссылка",Ссылка);
	Запрос.УстановитьПараметр("ВидДвижения",ВидДвиженияНакопления.Расход);
	ТЗ = Запрос.Выполнить().Выгрузить();
	
	КурсУпр = МодульВалютногоУчета.ПолучитьКурсВалют(Константы.ВалютаУправленческогоУчета.Получить(), Дата);
	
	Для каждого стр из ТЗ цикл
		
		стр.сумма = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(стр.сумма, Валюта, Константы.ВалютаУправленческогоУчета.Получить(),
		КурсВзаиморасчетов, КурсУпр.Курс, КратностьВзаиморасчетов, КурсУпр.Кратность);
		стр.суммаДокумента = МодульВалютногоУчета.ПересчитатьИзВалютыВВалюту(стр.суммаДокумента, Валюта, Константы.ВалютаУправленческогоУчета.Получить(),
		КурсВзаиморасчетов, КурсУпр.Курс, КратностьВзаиморасчетов, КурсУпр.Кратность);
		
	конеццикла;
	
	
	Возврат ТЗ;
	
КонецФункции


Функция ПроверитьДанные(ТаблицаДанных)
	
	Можно = истина;	
	Возврат Можно;
	
КонецФункции


Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	// Вставити вміст обробника.
	Если Товары.Количество()=0 тогда
		Сообщить("Отсутствуют элементы в табличной части "+"Товары");
		Отказ = истина;
		Возврат;
	КонецЕсли;
	
	Движения.ПартииТоваров.Записывать = истина;
	Движения.ПартииТоваров.Очистить(); // Очищаем данные в регистре связанные с этим документом для защиты от дублирования при перепроведениии
	Движения.ПартииТоваров.Записать(); // Записываем очищение
	
	
	ТаблицаПартий = Движения.ПартииТоваров.Выгрузить(); // Выгружаем параметры колонок в виртуальную таблицу
	Запрос = новый Запрос;  // Создаем запрос для выборки нужных нам данных
	Запрос.Текст = "ВЫБРАТЬ
	               |	РеализацияТоваровТовары.Номенклатура КАК Номенклатура,
	               |	РеализацияТоваровТовары.Количество КАК Количество,
	               |	РеализацияТоваровТовары.Сумма КАК Сумма,
	               |	РеализацияТоваровТовары.Ссылка.Дата КАК Дата,
	               |	РеализацияТоваровТовары.Ссылка.Склад КАК Склад,
	               |	ПартииТоваровОстатки.Партия КАК Партия,
	               |	ЕстьNULL(ПартииТоваровОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток,
	               |	ПартииТоваровОстатки.СуммаОстаток КАК СуммаОстаток
	               |ИЗ
	               |	Документ.РеализацияТоваров.Товары КАК РеализацияТоваровТовары
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ПартииТоваров.Остатки(&Дата, ) КАК ПартииТоваровОстатки
	               |		ПО РеализацияТоваровТовары.Номенклатура = ПартииТоваровОстатки.Номенклатура
	               |			И РеализацияТоваровТовары.Ссылка.Склад = ПартииТоваровОстатки.Склад
	               |ГДЕ
	               |	РеализацияТоваровТовары.Ссылка = &Ссылка
	               |ИТОГИ
	               |	МИНИМУМ(Количество),
	               |	МИНИМУМ(Сумма),
	               |	СУММА(КоличествоОстаток),
	               |	СУММА(СуммаОстаток)
	               |ПО
	               |	Номенклатура";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Дата", Дата);
	
	МоиКурс = МодульВалютногоУчета.ПолучитьКурсВалют(Валюта, Дата);
	Если МоиКурс.Курс = 0 и МоиКурс.Кратность = 0 тогда
		Сообщить("Курс валюты не задан");
		Отказ = истина;
		Возврат;
	конецесли;
	

	
	ВыборкаПоТоварам = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);  // Построчно сравниваем кол-во товара и кол-во на остатке даннного товара
	Пока ВыборкаПоТоварам.Следующий() цикл
		Если ВыборкаПоТоварам.Количество > ВыборкаПоТоварам.КоличествоОстаток тогда
			Мес = новый СообщениеПользователю;
			Мес.Текст = "Недостаточно товара "+Строка(ВыборкаПоТоварам.Номенклатура);
			Мес.Сообщить();
			отказ = истина;
			
		Иначе
			//  Описание
			Если не отказ тогда // Проверка на недостаток товара на предыдущих товара, если такое было - отказ будет истина
				НаСписание = ВыборкаПоТоварам.Количество;  // Кол-во товара которое необходимо списать
				ВыборкаПоПартиями = ВыборкаПоТоварам.Выбрать(ОбходРезультатаЗапроса.Прямой);
				Пока ВыборкаПоПартиями.Следующий() цикл
					КСписанию = Мин(НаСписание, ВыборкаПоПартиями.КоличествоОстаток);
					Если КСписанию = ВыборкаПоПартиями.КоличествоОстаток тогда
						СуммаСписания = ВыборкаПоПартиями.СуммаОстаток;
					Иначе 
						СуммаСписания = (ВыборкаПоПартиями.СуммаОстаток / ВыборкаПоПартиями.КоличествоОстаток) * КСписанию;
					КонецЕсли;
					
					Движ = ТаблицаПартий.Добавить(); // Добавляем таблицу в отдельную переменную
					ЗаполнитьЗначенияСвойств(Движ, ВыборкаПоПартиями); // Заполняем значениями
					Движ.Период = Дата;
					Движ.Активность = Истина;
					Движ.Количество = КСписанию;
					Движ.Сумма = СуммаСписания;
					НаСписание = НаСписание - КСписанию;
					Если НаСписание = 0 тогда // Когда кол-во на списание станет равно нулю прерываем цикл.
						Прервать;
					КонецЕсли;
				КонецЦикла;
				
				//Если (ВыборкаПоПартиями.СуммаОстаток / ВыборкаПоПартиями.КоличествоОстаток) < (ВыборкаПоПартиями.Сумма / ВыборкаПоПартиями.Количество) тогда   // Сравниваем закупочную цену с ценой продажи. В случае если закупочная ниже чем продажи - выводим уведомление.
				//	Сообщить("Цена продажи ниже чем себестоимость");
				//КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если не отказ тогда
		ТаблицаПартий.ЗаполнитьЗначения(ВидДвиженияНакопления.Расход, "ВидДвижения"); // Заполняем параметр "Вид движения"
		Движения.ПартииТоваров.Загрузить(ТаблицаПартий); // Записываем данные в регистр
	КонецЕсли;
	
	
	
	ТаблицаДляПроведения = ПолучитьДанные();  // Путем запроса заполняем таблицу нужными данными
	
	МожноПроводить = ПроверитьДанные(ТаблицаДляПроведения); // Проверка данные
	
	Если не МожноПроводить тогда  // Если проводить нельзя, прерываем обработку проведения.
		Отказ = истина;
		Возврат;
	Конецесли;
	
	ТаблицаДляПродаж = ТаблицаДляПроведения.Скопировать(,"Период, Контрагент, Номенклатура, Количество, Сумма");
	ТаблицаДляТоваровНаСкладах = ТаблицаДляПроведения.Скопировать(,"ВидДвижения, Период, Склад, Номенклатура, Количество");
	Массив = Новый Массив;
	Массив.Добавить(ТаблицаДляПроведения[0]); // Массив в котором индект 1ой строки таблицы
	ТаблицаДляВзаиморасчетов = ТаблицаДляПроведения.Скопировать(Массив,"ВидДвижения, Период, Контрагент, СуммаДокумента"); // Передаем только одну строку в которой есть все нужные нам данные
	ТаблицаДляВзаиморасчетов.Колонки.СуммаДокумента.Имя="Сумма";  // Так как в виртуальной таблице и регистре названия столбцов не совпадают - переименовываем столбец в виртуальной таблице
	
	
	
	Движения.Продажи.Записывать = Истина;
	Движения.ТоварыНаСкладе.Записывать = Истина;
	Движения.Взаиморасчеты.Записывать = Истина;
	
	// Загружаем все, сформированные с помощью таблиц данные, в регистры.
	Движения.Продажи.Загрузить(ТаблицаДляПродаж);
	Движения.ТоварыНаСкладе.Загрузить(ТаблицаДляТоваровНаСкладах);
	Движения.Взаиморасчеты.Загрузить(ТаблицаДляВзаиморасчетов);
КонецПроцедуры
