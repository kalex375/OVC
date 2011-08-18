/**
 * @author Kravchenko A.V.
 */
Ext.onReady(function(){

    SyntaxHighlighter.config.clipboardSwf = 'scripts/clipboard.swf';
    
    Ext.QuickTips.init();
    
    Ext.app.viewport = new Ext.Viewport({
        id: 'viewport_main',
        layout: 'border',
        renderTo: Ext.getBody(),
        items: [{
            region: 'north',
            xtype: 'panel',
            el: 'header'
        }, {
            region: 'west',
            xtype: 'panel',
            split: true,
            collapseMode: 'mini',
            width: 200,
            minSize: 150,
			layout: 'border',
            items: [{
                xtype: 'com.navigationtree',
				id:'tree_panel',
				region:'north',
            }, {
                xtype: 'panel',
				id:'browser_panel',
				region:'center',
				layout: 'fit',
                border: false
            }]
        }, {
            region: 'center',
            xtype: 'com.mainpanel',
			id:'taskmain_panel'
        }]
    });
    
});
