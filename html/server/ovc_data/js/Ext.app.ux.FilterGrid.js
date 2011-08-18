/**
 * @author Kravchenko A.V.
 *
 */
Ext.ns('Ext.app.ux');

/**
 * @class Ext.app.ux.FilterGrid
 * @extends Ext.grid.GridPanel
 *
 *	Tаблиц c фильтром
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype ux.filtergrid
 */
Ext.app.ux.FilterGrid = Ext.extend(Ext.grid.GridPanel, {
    /**
     * @cfg {Bool} Отображать фильтр
     */
    filterShow: true,
    
    /**
     * @cfg {Object} Функция парсинга параметров фильра
     */
    filterParsFunc: Ext.app.util.parseFilter,
    
    /**
     * @property {Bool} editfilter true если редактируется фильтр
     */
    editFilter: false,
    
    /**
     * @cfg {String} Название объектов
     */
    objectName: 'records',
    
    /**
     * @property {Bool} Авто применение фильтра
     */
    autoApplyFilter: true,
    
    
    /**
     * @property {String} Строка фильтра после парсинга
     */
    filterStr: '',
    /**
     * @private
     */
    initComponent: function(){
        //Set default params
        if (this.store) {
            this.store.paramNames.start = 'p_start';
            this.store.paramNames.limit = 'p_limit';
            this.store.setBaseParam('p_start', 0);
            this.store.setBaseParam('p_limit', 25);
            this.store.setBaseParam('p_filter', '');
        };
        
        this.idPrefix = Ext.id();
        
        if (!this.bbar) {
            this.bbar = new Ext.PagingToolbar({
                pageSize: 25,
                store: this.store,
                displayInfo: true,
                displayMsg: 'Displaying ' + this.objectName + ' {0} - {1} of {2}',
                emptyMsg: 'No ' + this.objectName + ' to display'
            });
        };
        
        btnFilter = new Ext.Button({
            ref: '../../btnFilter',
            iconCls: 'icon_filter_del',
			scope:this,
            handler: function(item, passed){
			  this.resetFilter();
            }
        });
        
		this.bbar.insert(11,{xtype:'tbseparator'});
		this.bbar.insertButton(12,btnFilter);
		this.bbar.insert(13,{xtype:'tbseparator'});
	
	
		Ext.apply(this, {
            trackMouseOver: true,
            loadMask: true,
            sm: new Ext.grid.RowSelectionModel({
                singleSelect: true
            })
			,columnLines: true
        });

        Ext.app.ux.FilterGrid.superclass.initComponent.call(this);
        
        
        if (!this.filterShow) {
            return
        };
        this.addEvents(        /**
         * @event filter
         * Fires when filter process is finished
         * @param {Object} data of the new entry
         */
        'filter');
        
        //this.cls = 'x-grid3-quickadd';
        
        // The customized header template
        this.initTemplates();
        
        // add our fields after view is rendered
        this.getView().afterRender = this.getView().afterRender.createSequence(this.renderFilterFields, this);
        
        // init handlers
        this.filterHandlers = {
            scope: this,
            blur: function(){
                this.setFilter.defer(250, this);
            },
            specialkey: function(f, e){
                if (e.getKey() == e.ENTER) {
                    e.stopEvent();
                    f.el.blur();
                    if (f.triggerBlur) {
                        f.triggerBlur();
                    }
                }
            }
        };
    },
    
    /**
     * renders the quick add fields
     */
    renderFilterFields: function(){
        Ext.each(this.getCols(), function(column){
            if (column.editor) {
                column.filterField = column.editor.cloneConfig({
                    allowBlank: true
                });
                
                if (column.doubleInp) {
                    column.filterField2 = column.editor.cloneConfig({
                        allowBlank: true
                    });
                    column.filterField2.render(this.getFilterWrap(column, 2));
                    column.filterField2.on(this.filterHandlers);
                    column.filterField2.on('focus', this.onFilterFocus, this);
                }
                column.filterField.render(this.getFilterWrap(column));
                
                column.filterField.on(this.filterHandlers);
                column.filterField.on('focus', this.onFilterFocus, this);
            }
        }, this);
        
        this.colModel.on('configchange', this.syncFields, this);
        this.colModel.on('hiddenchange', this.syncFields, this);
        this.on('resize', this.syncFields);
        this.on('columnresize', this.syncFields);
        this.syncFields();
        
    },
    
    /**
     * @private
     */
    setFilter: function(){
    
        // check if all filter fields are blured
        var hasFocus;
        Ext.each(this.getCols(true), function(item){
            if ((item.filterField && item.filterField.hasFocus) || (item.filterField2 && item.filterField2.hasFocus)) {
                hasFocus = true;
            }
        }, this);
        
        // only fire a 'filter' if no FilterField is focused
        if (!hasFocus) {
            var data = {};
            var needFire = false;
            Ext.each(this.getCols(true), function(item){
                if (item.filterField) {
                    if (item.filterField.getValue() != '') {
                    
                        data[item.dataIndex] = {};
                        data[item.dataIndex].type = item.typeFilterData;
                        data[item.dataIndex].filter = item.filterField.getValue();
                    };
                                    };
                if (item.filterField2) {
                    if (item.filterField2.getValue() != '') {
                    
                        if (!data[item.dataIndex]) {
                            data[item.dataIndex] = {};
                        };
                        data[item.dataIndex].type = item.typeFilterData;
                        data[item.dataIndex].filter2 = item.filterField2.getValue();
                    }
                };
                            }, this);
            
            
            if (this.filterParsFunc) {
                var old_filter = this.filterStr;
                this.filterStr = this.filterParsFunc(data)
                if (old_filter != this.filterStr) {
                    needFire = true;
                }
            }
            if (needFire) {
                if (this.fireEvent('filter', data, this.filterStr)) {
                    if (this.autoApplyFilter) 
                        this.applyFilter();
                }
            }
            
            this.editFilter = false;
        }
        
    },
    
    /**
     * Применение фильтар
     *
     * @param {String} Строка фильтра
     *
     */
    applyFilter: function(f){
    
        f = f ? f : this.filterStr;
        
        if (this.store) {
            this.store.setBaseParam('p_filter', f);
            this.store.load();
        };
            },
    
    /**
     * gets columns
     *
     * @param {Boolean} visibleOnly
     * @return {Array}
     */
    getCols: function(visibleOnly){
        if (visibleOnly === true) {
            var visibleCols = [];
            Ext.each(this.colModel.config, function(column){
                if (!column.hidden) {
                    visibleCols.push(column);
                }
            }, this);
            return visibleCols;
        }
        return this.colModel.config;
    },
    
    /**
     * returns wrap el for quick add filed of given col
     *
     * @param {Ext.grid.Colum} col
     * @return {Ext.Element}
     */
    getFilterWrap: function(column, d){
        if (d == '2') {
            return Ext.get(this.idPrefix + column.id + 2);
        }
        else {
            return Ext.get(this.idPrefix + column.id);
        }
    },
    
    /**
     * @private
     */
    initTemplates: function(){
        this.getView().templates = this.getView().templates ? this.getView().templates : {};
        var ts = this.getView().templates;
        
        var newRows = '';
        var newRows2 = '';
        
        var cm = this.colModel;
        var fields = this.getStore().recordType.prototype.fields;
        var ncols = cm.getColumnCount();
        for (var i = 0; i < ncols; i++) {
            var colId = cm.getColumnId(i);
            // console.log( fields.items[i].type );
            var fieldName = cm.getDataIndex(i);
            if (fieldName) {
                var t = fields.itemAt(fields.findIndex('name', fieldName)).type.type;
                
                if (t == 'int' || t == 'float' || t == 'date') {
                    cm.getColumnById(colId).typeFilterData = t;
                    cm.getColumnById(colId).doubleInp = true;
                    
                }
                else {
                
                    cm.getColumnById(colId).typeFilterData = 'string';
                }
            }
            newRows2 += '<td><div class="x-small-editor" style ="padding-top:1px;" id="' + this.idPrefix + colId + '2' + '"></td>';
            newRows += '<td><div class="x-small-editor" id="' + this.idPrefix + colId + '"></td>';
        }
        
        ts.header = new Ext.Template('<table border="0" cellspacing="0" cellpadding="0" style="{tstyle}">', '<thead><tr class="x-grid3-hd-row">{cells}</tr></thead>', '<tbody><tr class="new-row">', newRows, '</tr><tr class="new-row2">', newRows2, '</tr></tbody>', '</table>');
    },
    
    /**
     * @private
     */
    syncFields: function(){
        var newRowEl = Ext.get(Ext.DomQuery.selectNode('tr[class=new-row]', this.getView().mainHd.dom));
        var newRowEl2 = Ext.get(Ext.DomQuery.selectNode('tr[class=new-row2]', this.getView().mainHd.dom));
        
        var columns = this.getCols();
        for (var column, tdEl, tdEl2, i = columns.length - 1; i >= 0; i--) {
        
            column = columns[i];
            
            tdEl = this.getFilterWrap(column).parent();
            
            tdEl2 = Ext.get(this.idPrefix + column.id + 2).parent();
            
            
            // resort columns
            newRowEl.insertFirst(tdEl);
            
            newRowEl2.insertFirst(tdEl2);
            
            
            
            // set hidden state
            tdEl.dom.style.display = column.hidden ? 'none' : '';
            tdEl2.dom.style.display = column.hidden ? 'none' : '';
            
            // resize
            //tdEl.setWidth(column.width);
            if (column.filterField) {
                column.filterField.setSize(column.width - 1);
            }
            if (column.filterField2) {
                column.filterField2.setSize(column.width - 1);
            }
            
        }
    },
    
    /**
     * @private
     */
    onFilterFocus: function(){
        this.editFilter = true;
        //Ext.each(this.getCols(true), function(item){
        //    if(item.editor){
        //        item.editor.setDisabled(false);
        //    }
        //}, this);
    },
    
    /**
     * Reset FilterFileds value
     */
    resetFilter: function(){
    
        var columns = this.colModel.config;
        for (var i = 0, len = columns.length; i < len; i++) {
            if (columns[i].filterField) {
                columns[i].filterField.setValue('');
            }
            if (columns[i].filterField2) {
                columns[i].filterField2.setValue('');
            }
        }
        this.filterStr = '';
        if (this.store) {
            this.store.setBaseParam('p_filter', '');
            this.store.reload();
        };
            }
});
Ext.reg("ux.filtergrid", Ext.app.ux.FilterGrid);
