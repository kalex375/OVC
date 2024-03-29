/*
 * ====================================================================
 * Copyright (c) 2004-2010 TMate Software Ltd.  All rights reserved.
 *
 * This software is licensed as described in the file COPYING, which
 * you should have received as part of this distribution.  The terms
 * are also available at http://svnkit.com/license.html
 * If newer versions of this license are posted there, you may use a
 * newer version instead, at your option.
 * ====================================================================
 */
package org.tmatesoft.svn.core.internal.wc;

import java.io.InputStream;


/**
 * @version 1.3
 * @author  TMate Software Ltd.
 */
public interface ISVNPropertyComparator {

    public void propertyAdded(String name, InputStream value, int length);

    public void propertyDeleted(String name);

    public void propertyChanged(String name, InputStream newValue, int length);
}
