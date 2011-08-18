/**
 * @author Kravchenko A.V.
 *
 */
Ext.ns('Ext.app.ux');

/**
 * @class Ext.app.ux.ComboBoxYN
 * @extends Ext.form.ComboBox
 *
 *	ComboBox для выбора Да/Нет
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype ux.comboboxyn
 */
Ext.app.ux.ComboBoxYN = Ext.extend(/*Ext.form.ComboBox*/Ext.ux.form.SelectBox, {

    initComponent: function(){
        Ext.apply(this, {
            typeAhead: false,
            triggerAction: 'all',
            lazyRender: true,
            mode: 'local',
            store: new Ext.data.ArrayStore({
                id: 0,
                fields: ['code', 'name'],
                data: [['T', 'Yes'], ['F', 'No']]
            }),
            valueField: 'code',
            displayField: 'name'
        
        });
        
        Ext.app.ux.ComboBoxYN.superclass.initComponent.apply(this, arguments);
    }
});
