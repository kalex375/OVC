/**
 * @author Kravchenko A.V.
 */
Ext.ns('Ext.app.util');

/**
 *  Переводит объект в строку параметров для вызова оброботчика на сервере
 *  p_ovc_http.exec_command
 *
 * @param {Object} Объект каждое свойство которого параметр процедуры
 * @param {string} префикс подстовляется к имени параметра(свойства объекта)
 * @return {string} Строка параметров вида <#>param_name<@>type<@>value<#><#>param_name_2<@>type<@>value<#>
 */
Ext.app.util.parseParams = function(a, prefix){
    var m_params;
    if (!prefix) {
        prefix = ''
    }
    if (a) {
        for (var i in a) {
            b = typeof a[i];
            switch (b) {
                case 'number':
                    m_params_type = 'NUM';
                    break;
                case 'date':
                    m_params_type = 'DAT';
                    break;
                case 'integer':
                    m_params_type = 'INT';
                    break;
                case 'boolean':
                    m_params_type = 'BOL';
                    break;
                default:
                    m_params_type = 'STR';
                    break;
            };
            value = a[i];
            if (value == null) {
                value = ''
            };
            if (m_params) {
                m_params = m_params + '<#>' + prefix + i + '<@>' + m_params_type + '<@>' + value + '<#>';
            }
            else {
                m_params = '<#>' + prefix + i + '<@>' + m_params_type + '<@>' + value + '<#>'
            };
                    }
        return m_params;
    }
};

/**
 *  Переводит объект record в строку параметров для вызова оброботчика на сервере
 *  p_ovc_http.exec_command
 *
 * @param {Object} Объект record из store таблицы
 * @param {string} префикс подстовляется к имени параметра(свойства объекта)
 * @return {string} Строка параметров вида <#>param_name<@>type<@>value<#><#>param_name_2<@>type<@>value<#>
 */
Ext.app.util.parseParamsRec = function(rec, prefix){
    var m_params;
    if (!prefix) {
        prefix = ''
    }
    if (rec) {
        for (var i in rec.data) {
            if (rec.fields.map[i]) {
                b = rec.fields.map[i].type.type;
            }
            else {
                b = 'string'
            };
            switch (b) {
                case 'int':
                    m_params_type = 'INT';
                    break;
                case 'float':
                    m_params_type = 'NUM';
                    break;
                case 'date':
                    m_params_type = 'DAT';
                    break;
                case 'boolean':
                    m_params_type = 'BOL';
                    break;
                default:
                    m_params_type = 'STR';
                    break;
            };
            value = rec.data[i];
            if (value == null) {
                value = ''
            };
            if (m_params) {
                m_params = m_params + '<#>' + prefix + i + '<@>' + m_params_type + '<@>' + value + '<#>';
            }
            else {
                m_params = '<#>' + prefix + i + '<@>' + m_params_type + '<@>' + value + '<#>'
            };
                    }
        return m_params;
    }
};

Ext.ns('Ext.app.util');

/**
 *  Переводит объект в строку условий для SQL
 *
 * @param {Object} Объект каждое свойство которого поле
 * @param {string} префикс подстовляется к имени параметра(свойства объекта)
 * @return {string} Строка условий вида 'and field1=filter and field2=filter and'
 */
Ext.app.util.parseFilter = function(a, prefix){
    var filter = '';
    
    if (!prefix) {
        prefix = ''
    }
    if (a) {
        for (var i in a) {
            switch (a[i].type) {
                case 'int':
                    if (a[i].filter && a[i].filter2) {
                        filter += ' and ' + i + ' >= ' + a[i].filter + ' and ' + i + '<=' + a[i].filter2;
                    }
                    else 
                        if (a[i].filter) {
                            filter += ' and ' + i + ' = ' + a[i].filter;
                        }
                        else 
                            if (a[i].filter2) {
                                filter += ' and ' + i + ' = ' + a[i].filter2;
                            }
                    break;
                case 'float':
                    if (a[i].filter && a[i].filter2) {
                        filter += ' and ' + i + ' >= ' + a[i].filter + ' and ' + i + '<=' + a[i].filter2;
                    }
                    else 
                        if (a[i].filter) {
                            filter += ' and ' + i + ' = ' + a[i].filter;
                        }
                        else 
                            if (a[i].filter2) {
                                filter += ' and ' + i + ' = ' + a[i].filter2;
                            }
                    break;
                case 'date':
                    if (a[i].filter && a[i].filter2) {
                        filter += " and " + i + " >= to_date('" + a[i].filter.format('d.m.Y H:i:s') + "','DD.MM.YYYY HH24:MI:SS') and " + i + "<= to_date('" + a[i].filter2.format('d.m.Y H:i:s') + "','DD.MM.YYYY HH24:MI:SS')";
                    }
                    else 
                        if (a[i].filter) {
                            filter += " and " + i + " = to_date('" + a[i].filter.format('d.m.Y H:i:s') + "','DD.MM.YYYY HH24:MI:SS')";
                        }
                        else 
                            if (a[i].filter2) {
                                filter += " and " + i + " = to_date('" + a[i].filter2.format('d.m.Y H:i:s') + "','DD.MM.YYYY HH24:MI:SS')";
                            }
                    break;
                case 'string':
                    var r_str = a[i].filter.trim();
                    r_str = r_str.replace(/\*/gi, '%');
                    r_str = r_str.replace(/\*/gi, '_');
                    filter += ' and ' + i + " like '" + r_str + "'";
                    break;
                default:
                    break;
            };
                    }
        return filter;
    }
};

/**
 * Показывает модальное окно с ошибкой
 *
 * @param {string} сообщение
 * @param {string} заголовок окна
 */
Ext.app.util.showError = function(msg, title){
    Ext.Msg.show({
        title: title || 'Error',
        msg: Ext.util.Format.ellipsis(msg, 2000),
        icon: Ext.Msg.ERROR,
        buttons: Ext.Msg.OK,
        minWidth: 1200 > String(msg).length ? 360 : 600
    });
};

/**
 *
 * Отправляет изменения таблицы на сервер
 *
 * Creates new remoteUpdater
 * @constructor
 * @param {Object} config A config object
 */
Ext.app.util.remoteUpdater = function(config){

    Ext.apply(this, config);
    
    //Ext.app.util.remoteUpdater.superclass.constructor.apply(this, arguments);
};

Ext.override(Ext.app.util.remoteUpdater, {
    /**
     * @cfg {String} url удалленой коианды.
     */
    url: 'p_ovc_http.exec_command',
    /**
     * @cfg {String} процедура для выполнения вставки записи.
     */
    insertCommand: null,
    /**
     * @cfg {String} процедура для обновления записи.
     */
    updateCommand: null,
    /**
     * @cfg {String} процедура для удаления записи.
     */
    deleteCommand: null,
    /**
     * @cfg {Object} таблица для которой выполняются команды.
     */
    grid: null,
    /**
     * @cfg {String} префикс для полей при передачина сервер.
     */
    prefix: '',
    
    
    /**
     * Обновить запись
     * @param Запись которую нужно обновить
     */
    updateRecord: function(rec){
        this.sendCommand(rec, 'update');
    },
    
    
    /**
     * Добавить запись
     * @param Запись которую нужно вставить
     */
    insertRecord: function(rec){
        this.sendCommand(rec, 'insert');
    },
    
    /**
     * Удалть запись
     * @param Запись которую нужно удалить
     */
    deleteRecord: function(rec){
        this.sendCommand(rec, 'delete');
    },
    
    /**
     * Послать команду на сервер
     * @param (Record) запись из таблици над которой выполняется операция
     * @param (string) {insert, update, delete}
     */
    sendCommand: function(rec, command){
        var o = {
            url: this.url,
            method: 'post',
            callback: this.requestCallback,
            scope: this.grid,
            rec: rec
        };
        switch (command) {
            case 'insert':
                o.params = {
                    p_command: this.insertCommand
                };
                break;
            case 'update':
                o.params = {
                    p_command: this.updateCommand
                };
                break;
            case 'delete':
                o.params = {
                    p_command: this.deleteCommand
                };
                break;
        };
        
        o.command = command;
        
        o.params.p_params = Ext.app.util.parseParamsRec(rec, this.prefix);
        Ext.Ajax.request(o);
    }, // eof sendCommand
    requestCallback: function(options, success, response){
    
        if (true !== success) {
            Ext.app.util.showError(response.responseText);
            return;
        }
        try {
            var o = Ext.util.JSON.decode(response.responseText);
        } 
        catch (e) {
            Ext.app.util.showError(response.responseText, 'Cannot decode JSON object');
            return;
        }
        if (true !== o.success) {
            Ext.app.util.showError(o.errormsg, o.errors.title);
            return;
        }
        
        switch (options.command) {
            case 'insert':
                
                for (var i in o.data) {
                    options.rec.set(i.substr(this.updater.prefix.length), o.data[i]);
                }
                ;                delete (options.rec.data.newRecord);
                
                options.rec.commit();
                break;
                
            case 'update':
                options.rec.commit();
                break;
                
            case 'delete':
                this.store.remove(options.rec);
                break;
        };
        
            } // eof requestCallback
});
