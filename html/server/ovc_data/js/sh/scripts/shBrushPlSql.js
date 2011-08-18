SyntaxHighlighter.brushes.PlSql = function()
{
	var funcs	=	'avg';

	var keywords =	'replace access else modify start add exclusive noaudit select all exists nocompress session' +  
                  'alter file not set and float notfound share any for nowait size arraylen from null smallint' +  
                  'as grant number sqlbuf asc group of successful audit having offline synonym between identified on sysdate' +  
                  'by immediate online table char in option then check increment or to cluster index order trigger' +  
                  'column initial pctfree uid comment insert prior union compress integer privileges unique' +
                  'connect intersect public update create into raw user current is rename validate' +
                  'date level resource values decimal like revoke varchar default lock row varchar2' +
                  'delete long rowid view desc maxextents rowlabel whenever distinct minus rownum where' +
                  'drop mode rows with admin cursor found mount after cycle function next' +
                  'allocate database go new analyze datafile goto noarchivelog archive dba groups nocache' +
                  'archivelog dec including nocycle authorization declare indicator nomaxvalue' +
                  'avg disable initrans nominvalue backup dismount instance none begin double int noorder' +
                  'become dump key noresetlogs before each language normal block enable layer nosort' +
                  'body end link numeric cache escape lists off cancel events logfile old' +
                  'cascade except manage only change exceptions manual open character exec max optimal' +
                  'checkpoint explain maxdatafiles own close execute maxinstances package' +
                  'cobol extent maxlogfiles parallel commit externally maxloghistory pctincrease' +
                  'compile fetch maxlogmembers pctused constraint flush maxtrans plan' +
                  'constraints freelist maxvalue pli contents freelists min precision' +
                  'continue force minextents primary controlfile foreign minvalue private' +
                  'count fortran module procedure profile savepoint sqlstate tracing quota schema statement_id transaction' +
                  'read scn statistics triggers real section stop truncate recover segment storage under' +
                  'references sequence sum unlimited referencing shared switch until resetlogs snapshot system use' +
                  'restricted some tables using reuse sort tablespace when role sql temporary write' +
                  'roles sqlcode thread work rollback sqlerror time abort between crash digits' +
                  'accept binary_integer create dispose access body current distinct add boolean currval do' +
                  'all by cursor drop alter case database else and char data_base elsif' +
                  'any char_base date end array check dba entry arraylen close debugoff exception' +
                  'as cluster debugon exception_init asc clusters declare exists' +
                  'assert colauth decimal exit assign columns default false' +
                  'at commit definition fetch authorization compress delay float' +
                  'avg connect delete for base_table constant delta form' +
                  'begin count desc from function new release sum' +
                  'generic nextval remr tabauth goto nocompress rename table' +
                  'grant not resource tables group null return task having number reverse terminate' +
                  'identified number_base revoke then if of rollback to in on rowid true index open' +
                  'rowlabel type indexes option rownum union indicator or rowtype unique insert order run update' +
                  'integer others savepoint use intersect out schema values into package select varchar' +
                  'is partition separate varchar2 level pctfree set variance like positive size view' +
                  'limited pragma smallint views loop prior space when max private sql where' +
                  'min procedure sqlcode while minus public sqlerrm with mlslabel raise start work' +
                  'mod range statement xor mode real stddev natural record subtype';


	var operators =	'any';

	this.regexList = [
		{ regex: /--(.*)$/gm,												css: 'comments' },			// one line and multiline comments
		{ regex: SyntaxHighlighter.regexLib.multiLineCComments,				css: 'comments' },			// multiline comments		{ regex: SyntaxHighlighter.regexLib.multiLineDoubleQuotedString,	css: 'string' },			// double quoted strings
		{ regex: SyntaxHighlighter.regexLib.multiLineSingleQuotedString,	css: 'string' },			// single quoted strings
		{ regex: new RegExp(this.getKeywords(funcs), 'gmi'),				css: 'color2' },			// functions
		{ regex: new RegExp(this.getKeywords(operators), 'gmi'),			css: 'color1' },			// operators and such
		{ regex: new RegExp(this.getKeywords(keywords), 'gmi'),				css: 'keyword' }			// keyword
		];
};

SyntaxHighlighter.brushes.PlSql.prototype	= new SyntaxHighlighter.Highlighter();
SyntaxHighlighter.brushes.PlSql.aliases	= ['plsql'];