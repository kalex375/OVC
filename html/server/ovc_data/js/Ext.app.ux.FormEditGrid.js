/**
 * @author Kravchenko A.V.
 *
 */
Ext.ns('Ext.app.ux');

/**
 * @class Ext.app.ux.FormEditGrid
 * @extends Ext.app.ux.FilterGrid
 *
 *	Редактируемая таблица. Вввод значений осуществляеется через форуму.
 *	Данные сразу же отпраляются на сервер с помощью remoteUpdater
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype ux.formeditgrid
 */
Ext.app.ux.FormEditGrid = Ext.extend(Ext.app.ux.FilterGrid, {

    /**
     * @cfg {object} config updater.
     */
    updater: null,
    
    /**
     * @cfg {object} config recordForm.
     */
    recordForm: null,
    
    /**
     * @cfg {String} текст для кнопки Add.
     */
    textAdd: 'Add',
    /**
     * @cfg {String} всплывающая подсказка для кнопки Add
     */
    tooltipAdd: '',
    /**
     * @cfg {String} текст для кнопки Edit.
     */
    textEdit: 'Edit',
    /**
     * @cfg {String} всплывающая подсказка для кнопки Edit
     */
    tooltipEdit: '',
    /**
     * @cfg {String} текст для кнопки Delete.
     */
    textDelete: 'Delete',
    /**
     * @cfg {String} всплывающая подсказка для кнопки Delete
     */
    tooltipDelete: '',
    
    /**
     * @cfg {String} Поле с имение объекта
     */
    nameField: '',
    
    initComponent: function(){
    
    
        this.updater = this.updater ? this.updater : {};
        
        this.updater = new Ext.app.util.remoteUpdater(this.updater);
        
        this.updater.grid = this;
        
        
        this.recordForm = this.recordForm ? this.recordForm : {};
        
        Ext.applyIf(this.recordForm, {
            title: 'Edit record',
            iconCls: 'icon_table_edit',
            okText: 'Save',
            okIconCls: 'icon_save',
            cancelIconCls: 'icon_cross',
            columnCount: 1,
            afterUpdateRecord: this.commitChanges,
            formConfig: {
                labelWidth: 80,
                buttonAlign: 'right',
                bodyStyle: 'padding-top:10px'
            }
        });
        this.recordForm.ignoreFields = this.recordForm.ignoreFields ? this.recordForm.ignoreFields : {};
        
        this.recordForm.ignoreFields.ID = true
        
        this.recordForm = new Ext.ux.grid.RecordForm(this.recordForm);
        
        // create row actions
        this.rowActions = new Ext.ux.grid.RowActions({
            actions: [],
            widthIntercept: Ext.isSafari ? 4 : 2,
            id: 'actions',
            getEditor: Ext.emptyFn
        });
        
        this.rowActions.on('action', this.onRowAction, this);
        
        if (this.updater.insertCommand || this.updater.updateCommand || this.updater.deleteCommand) {
            var tb = new Ext.Toolbar({});
			var bg = new Ext.ButtonGroup({columns: 6});
			
            if (this.updater.insertCommand) {
                bg.add({
                    text: this.textAdd,
					iconAlign: 'left',
					width:35,
                    tooltip: this.tooltipAdd,
                    iconCls: 'icon_record_add',
                    listeners: {
                        click: {
                            scope: this,
                            buffer: 200,
                            fn: function(btn){
                                this.onRowAction(this, this.addRecord(), 'icon_record_add', 0, 0, btn);
                            }
                        }
                    }
                })
				if (this.updater.deleteCommand||this.updater.updateCommand) {
					bg.add({xtype:'tbseparator'});
				}
            }
            if (this.updater.updateCommand) {
                bg.add({
                    text: this.textEdit,
					iconAlign: 'left',
					width:35,
                    tooltip: this.tooltipEdit,
                    iconCls: 'icon_record_edit',
                    listeners: {
                        click: {
                            scope: this,
                            buffer: 200,
                            fn: function(btn){
                                if (this.selModel.hasSelection()) {
                                    this.onRowAction(this, this.selModel.getSelected(), 'icon_record_edit', 0, 0, btn);
                                    
                                };
                                                            }
                        }
                    }
                })
				if (this.updater.deleteCommand) {
					bg.add({xtype:'tbseparator'});
				}
				
                var act = {
                    iconCls: 'icon_record_edit',
                    qtip: this.tooltipEdit
                };
                this.rowActions.actions.push(act);
                
            }
            if (this.updater.deleteCommand) {
                bg.add({
                    text: this.textDelete,
					iconAlign: 'left',
					width:35,
                    tooltip: this.tooltipDelete,
                    iconCls: 'icon_record_delete',
                    listeners: {
                        click: {
                            scope: this,
                            buffer: 200,
                            fn: function(btn){
                                if (this.selModel.hasSelection()) {
                                    this.onRowAction(this, this.selModel.getSelected(), 'icon_record_delete', 0, 0, btn);
                                };
                                                            }
                        }
                    }
                })
				
                var act = {
                    iconCls: 'icon_record_delete',
                    qtip: this.tooltipDelete
                
                };
                this.rowActions.actions.push(act);
            }
			tb.add(bg);
            this.tbar = tb;
        }
        if (this.rowActions.actions.length) {
            this.columns.push(this.rowActions);
        }
        
        Ext.apply(this, {
            plugins: [this.rowActions, this.recordForm]
        
        });
        
        Ext.app.ux.FormEditGrid.superclass.initComponent.apply(this, arguments);
    },
    onRender: function(){
        // call parent
        Ext.app.ux.FormEditGrid.superclass.onRender.apply(this, arguments);
        
        
    } // eo function onRender
    ,
    addRecord: function(){
        var store = this.store;
        if (store.recordType) {
            var rec = new store.recordType({
                newRecord: true
            });
            rec.fields.each(function(f){
                rec.data[f.name] = f.defaultValue || null;
            });
            rec.commit();
            store.add(rec);
            return rec;
        }
        return false;
    } // eo function addRecord
    ,
    onRowAction: function(grid, record, action, row, col, btn){
    
        switch (action) {
            case 'icon_record_add':
                this.recordForm.show(record, btn.getEl());
                break;
                
            case 'icon_record_delete':
                Ext.Msg.show({
                    title: 'Delete record?',
                    msg: 'Do you really want to delete <b>' + record.get(this.nameField) + '</b><br/>There is no undo.',
                    icon: Ext.Msg.QUESTION,
                    buttons: Ext.Msg.YESNO,
                    scope: this,
                    fn: function(response){
                        if ('yes' !== response) {
                            return;
                        }
                        this.updater.deleteRecord(this.selModel.getSelected());
                    }
                });
                
                
                break;
                
            case 'icon_record_edit':
                this.recordForm.show(record, grid.getView().getCell(row, col));
                break;
        }
    } // eo onRowAction
    ,
    commitChanges: function(rec){
        if (rec.data.newRecord) {
            this.grid.updater.insertRecord(rec);
            
        }
        else {
            this.grid.updater.updateRecord(rec)
        };
        
            } // eo function commitChanges
});

Ext.reg("ux.formeditgrid", Ext.app.ux.FormEditGrid);
