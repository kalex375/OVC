/**
 * @author Kravchenko A.V.
 */
Ext.ns('Ext.app.com');

/**
 * @class Ext.app.com.NavigationLoader
 * @extends Ext.ux.tree.XmlTreeLoader
 *
 * Загрузчик дерева задач. Во время загрузки XML  с сервера устанавливает дополнительные атрибуты для узлов.
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.navigationloader
 */
Ext.app.com.NavigationLoader = Ext.extend(Ext.ux.tree.XmlTreeLoader, {
    processAttributes: function(attr){
        if (true) {
            // Override these values for our folder nodes because we are loading all data at once.  If we were
            // loading each node asynchronously (the default) we would not want to do this:
            attr.loaded = true;
            attr.leaf = false;
            if (attr.expanded) {
                if (attr.expanded == "true") {
                    attr.expanded = true
                }
                else {
                    {
                        attr.expanded = false
                    }
                }
            };
                    }
    }
});

Ext.reg("com.navigationloader", Ext.app.com.NavigationLoader);

Ext.namespace("Ext.app.com");
/**
 * @class Ext.app.com.NavigationTree
 * @extends Ext.tree.TreePanel
 *
 * Дерево задач. Отображает дерево с доступными задачями
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.navigationtree
 */
Ext.app.com.NavigationTree = Ext.extend(Ext.tree.TreePanel, {
    initComponent: function(){
        Ext.apply(this, {
            id: 'tree-panel',
            height: 250,
            border: false,
            title: 'Tasks',
            margins: '0 0 5 5',
            cmargins: '0 0 0 0',
            lines: false,
            collapsible: true,
            autoScroll: true,
            rootVisible: false,
            root: new Ext.tree.AsyncTreeNode({
                id: 'ROOT_NODE'
            }),
            loader: new Ext.app.com.NavigationLoader({
                dataUrl: 'p_ovc_http.get_navigation_tree'
            }),
            
            listeners: {
                'render': function(tp){
                    tp.getSelectionModel().on('selectionchange', function(tree, node){
                        if (node.attributes.xtype) {
                            Ext.app.viewport.getComponent('taskmain_panel').loadTask(node.attributes, Ext.getCmp('browser_panel'))
                        }
                        else {
                            Ext.app.util.showError('Not implemented!');
                        };
                                            })
                    tp.selectPath('/ROOT_NODE/OVC_HOME');
                    
                }
            }
        
        });
        Ext.app.com.NavigationTree.superclass.initComponent.apply(this, arguments);
    },
    selectTask: function(id){
        this.selectPath(this.getNodeById(id).getPath());
        
    }
});

Ext.reg("com.navigationtree", Ext.app.com.NavigationTree);

Ext.namespace("Ext.app.com");
/**
 * @class Ext.app.com.MainPanel
 * @extends Ext.TabPanel
 *
 * Главная панель. На этой панели в виде закладок отображаюся выбраные задачи
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype com.mainpanel
 */
Ext.app.com.MainPanel = Ext.extend(Ext.TabPanel, {
    initComponent: function(){
        Ext.apply(this, {
            margins: '0 5 5 0',
            resizeTabs: true,
            minTabWidth: 135,
            tabWidth: 135,
            plugins: new Ext.ux.TabCloseMenu(),
            enableTabScroll: true,
            listeners: {
                'tabchange': function(tp, tab){
                    treePanel = Ext.getCmp('tree_panel')
                    if (treePanel) {
                        treePanel.selectTask(tab.id);
                    }
                }
            }
        });
        Ext.app.com.MainPanel.superclass.initComponent.apply(this, arguments);
    },
    
    /**
     *
     * Процедура загрузчик задач
     *
     * @param {string} Код задачи (OVC_HOME, ERROR_LOG...)
     * @param {Object} Дополнительная панель сбоку,
     * 				   предоставляемая для пользования задаче (например для отображения дерева объектов)
     */
    loadTask: function(task, apanel){
        var tab = Ext.getCmp(task.code);
        if (tab) {
            this.setActiveTab(tab);
        }
        else {
            var tab = Ext.create({
                id: task.code,
                title: task.text,
                iconCls: task.iconCls,
                apanel: apanel
            }, task.xtype);
            tab.loadPanel();
            var p = this.add(tab);
            this.setActiveTab(p);
        }
    }
    
});

Ext.reg("com.mainpanel", Ext.app.com.MainPanel);
