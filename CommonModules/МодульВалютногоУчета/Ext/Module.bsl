﻿&НаСервере
Функция ПолучитьКурсВалют(Валюта, дата) экспорт
	
	
	Ответ = Новый Структура;
	Фильтр = Новый Структура;
	Фильтр.Вставить("Валюта", Валюта);
	Курс = РегистрыСведений.КурсВалют.СрезПоследних(Дата, Фильтр);
	
	
	
	Если Курс.Количество()= 0 тогда
		Ответ.Вставить("Курс", 0);
		Ответ.Вставить("Кратность", 0);
	Иначе
		Ответ.Вставить("Курс", Курс[0].Курс);
		Ответ.Вставить("Кратность", Курс[0].Кратность);
	Конецесли;
	
	Возврат Ответ;
	
Конецфункции

&НаСервере
Функция ПересчитатьИзВалютыВВалюту(Сумма, ВалютаНач, ВалютаКон, ПоКурсуНач, ПоКурсуКон,
									ПОКратностьНач = 1, ПоКратностьКон = 1) экспорт
									
		Если (ВалютаНач = ВалютаКон) тогда
			
			Возврат Сумма;
		конецесли;
		
		Если (ПоКурсуНач = ПоКурсуКон) и (ПоКратностьНач = ПоКратностьКон) тогда
			Возврат Сумма;
		Конецесли;
		
		Если НЕ ЗначениеЗаполнено(ПоКурсуНач)
		или НЕ ЗначениеЗаполнено(ПоКурсуКон)
		или НЕ ЗначениеЗаполнено(ПоКратностьНач)
		или НЕ ЗначениеЗаполнено(ПоКРатностьКон) тогда
		Сообщить("ПересчитатьИзВалютыВВалюту(): при перерасчете Обнаружен нулевой курс");
		Возврат 0;
	Конецесли;
	
	НоваяСумма = (Сумма * ПоКурсуНач * ПоКратностьКон) / (ПоКурсуКон * ПоКратностьНач);
	Возврат Окр(НоваяСумма, 2);

									
									
Конецфункции