﻿Процедура ПересчитатьСумму(ТекСтрока) экспорт 
	
	ТекСтрока.Сумма = ТекСтрока.Цена * ТекСтрока.Количество;
	
КонецПроцедуры

Процедура ПересчитатьЦену(ТекСтрока) экспорт	
	
	Если ТекСтрока.Количество <> 0 тогда
	
	ТекСтрока.Цена = ТекСтрока.Сумма / ТекСтрока.Количество;
	
	Иначе 
	ТекСтрока.Цена = 0;
	КонецЕсли 
	
КонецПроцедуры