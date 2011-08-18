<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
        <table id="timeline">
        <tr>
            <th> ID carriage </th>
            <th> Type name </th>
        </tr>
            <xsl:for-each select="ROOT/ROW">
        <tr>
            <td>
                <xsl:value-of select="ID"/>
            </td>
            <td>
                <xsl:value-of select="TYPE"/>
            </td>
        </tr>
        </xsl:for-each>
        </table>
</xsl:template>
</xsl:stylesheet>