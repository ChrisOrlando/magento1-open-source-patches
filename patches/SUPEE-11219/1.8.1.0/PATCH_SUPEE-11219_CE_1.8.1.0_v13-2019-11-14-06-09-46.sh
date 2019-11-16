#!/bin/bash
# Patch apllying tool template
# v0.1.2
# (c) Copyright 2013. Magento Inc.
#
# DO NOT CHANGE ANY LINE IN THIS FILE.

# 1. Check required system tools
_check_installed_tools() {
    local missed=""

    until [ -z "$1" ]; do
        type -t $1 >/dev/null 2>/dev/null
        if (( $? != 0 )); then
            missed="$missed $1"
        fi
        shift
    done

    echo $missed
}

REQUIRED_UTILS='sed patch'
MISSED_REQUIRED_TOOLS=`_check_installed_tools $REQUIRED_UTILS`
if (( `echo $MISSED_REQUIRED_TOOLS | wc -w` > 0 ));
then
    echo -e "Error! Some required system tools, that are utilized in this sh script, are not installed:\nTool(s) \"$MISSED_REQUIRED_TOOLS\" is(are) missed, please install it(them)."
    exit 1
fi

# 2. Determine bin path for system tools
CAT_BIN=`which cat`
PATCH_BIN=`which patch`
SED_BIN=`which sed`
PWD_BIN=`which pwd`
BASENAME_BIN=`which basename`

BASE_NAME=`$BASENAME_BIN "$0"`

# 3. Help menu
if [ "$1" = "-?" -o "$1" = "-h" -o "$1" = "--help" ]
then
    $CAT_BIN << EOFH
Usage: sh $BASE_NAME [--help] [-R|--revert] [--list]
Apply embedded patch.

-R, --revert    Revert previously applied embedded patch
--list          Show list of applied patches
--help          Show this help message
EOFH
    exit 0
fi

# 4. Get "revert" flag and "list applied patches" flag
REVERT_FLAG=
SHOW_APPLIED_LIST=0
if [ "$1" = "-R" -o "$1" = "--revert" ]
then
    REVERT_FLAG=-R
fi
if [ "$1" = "--list" ]
then
    SHOW_APPLIED_LIST=1
fi

# 5. File pathes
CURRENT_DIR=`$PWD_BIN`/
APP_ETC_DIR=`echo "$CURRENT_DIR""app/etc/"`
APPLIED_PATCHES_LIST_FILE=`echo "$APP_ETC_DIR""applied.patches.list"`

# 6. Show applied patches list if requested
if [ "$SHOW_APPLIED_LIST" -eq 1 ] ; then
    echo -e "Applied/reverted patches list:"
    if [ -e "$APPLIED_PATCHES_LIST_FILE" ]
    then
        if [ ! -r "$APPLIED_PATCHES_LIST_FILE" ]
        then
            echo "ERROR: \"$APPLIED_PATCHES_LIST_FILE\" must be readable so applied patches list can be shown."
            exit 1
        else
            $SED_BIN -n "/SUP-\|SUPEE-/p" $APPLIED_PATCHES_LIST_FILE
        fi
    else
        echo "<empty>"
    fi
    exit 0
fi

# 7. Check applied patches track file and its directory
_check_files() {
    if [ ! -e "$APP_ETC_DIR" ]
    then
        echo "ERROR: \"$APP_ETC_DIR\" must exist for proper tool work."
        exit 1
    fi

    if [ ! -w "$APP_ETC_DIR" ]
    then
        echo "ERROR: \"$APP_ETC_DIR\" must be writeable for proper tool work."
        exit 1
    fi

    if [ -e "$APPLIED_PATCHES_LIST_FILE" ]
    then
        if [ ! -w "$APPLIED_PATCHES_LIST_FILE" ]
        then
            echo "ERROR: \"$APPLIED_PATCHES_LIST_FILE\" must be writeable for proper tool work."
            exit 1
        fi
    fi
}

_check_files

# 8. Apply/revert patch
# Note: there is no need to check files permissions for files to be patched.
# "patch" tool will not modify any file if there is not enough permissions for all files to be modified.
# Get start points for additional information and patch data
SKIP_LINES=$((`$SED_BIN -n "/^__PATCHFILE_FOLLOWS__$/=" "$CURRENT_DIR""$BASE_NAME"` + 1))
ADDITIONAL_INFO_LINE=$(($SKIP_LINES - 3))p

_apply_revert_patch() {
    DRY_RUN_FLAG=
    if [ "$1" = "dry-run" ]
    then
        DRY_RUN_FLAG=" --dry-run"
        echo "Checking if patch can be applied/reverted successfully..."
    fi
    PATCH_APPLY_REVERT_RESULT=`$SED_BIN -e '1,/^__PATCHFILE_FOLLOWS__$/d' "$CURRENT_DIR""$BASE_NAME" | $PATCH_BIN $DRY_RUN_FLAG $REVERT_FLAG -p0`
    PATCH_APPLY_REVERT_STATUS=$?
    if [ $PATCH_APPLY_REVERT_STATUS -eq 1 ] ; then
        echo -e "ERROR: Patch can't be applied/reverted successfully.\n\n$PATCH_APPLY_REVERT_RESULT"
        exit 1
    fi
    if [ $PATCH_APPLY_REVERT_STATUS -eq 2 ] ; then
        echo -e "ERROR: Patch can't be applied/reverted successfully."
        exit 2
    fi
}

REVERTED_PATCH_MARK=
if [ -n "$REVERT_FLAG" ]
then
    REVERTED_PATCH_MARK=" | REVERTED"
fi

_apply_revert_patch dry-run
_apply_revert_patch

# 9. Track patch applying result
echo "Patch was applied/reverted successfully."
ADDITIONAL_INFO=`$SED_BIN -n ""$ADDITIONAL_INFO_LINE"" "$CURRENT_DIR""$BASE_NAME"`
APPLIED_REVERTED_ON_DATE=`date -u +"%F %T UTC"`
APPLIED_REVERTED_PATCH_INFO=`echo -n "$APPLIED_REVERTED_ON_DATE"" | ""$ADDITIONAL_INFO""$REVERTED_PATCH_MARK"`
echo -e "$APPLIED_REVERTED_PATCH_INFO\n$PATCH_APPLY_REVERT_RESULT\n\n" >> "$APPLIED_PATCHES_LIST_FILE"

exit 0


SUPEE-11219_CE_1810 | CE_1.8.0.0 | v1 | c5a45ae17ef9ecbdfff007cdc1bfdbf3f25c1725 | Thu Nov 7 21:10:22 2019 +0000 | dea5540c9c3fc36cf3cddbd83f62a8ab10f9635f..HEAD

__PATCHFILE_FOLLOWS__
diff --git app/code/core/Mage/Admin/Helper/Data.php app/code/core/Mage/Admin/Helper/Data.php
index baf2f62832b..86cce2601f9 100644
--- app/code/core/Mage/Admin/Helper/Data.php
+++ app/code/core/Mage/Admin/Helper/Data.php
@@ -10,13 +10,13 @@
  * http://opensource.org/licenses/osl-3.0.php
  * If you did not receive a copy of the license and are unable to
  * obtain it through the world-wide-web, please send an email
- * to license@magentocommerce.com so we can send you a copy immediately.
+ * to license@magento.com so we can send you a copy immediately.
  *
  * DISCLAIMER
  *
  * Do not edit or add to this file if you wish to upgrade Magento to newer
  * versions in the future. If you wish to customize Magento for your
- * needs please refer to http://www.magentocommerce.com for more information.
+ * needs please refer to http://www.magento.com for more information.
  *
  * @category    Mage
  * @package     Mage_Admin
diff --git app/code/core/Mage/Admin/Model/User.php app/code/core/Mage/Admin/Model/User.php
index 80c5401e802..f38e7a96e76 100644
--- app/code/core/Mage/Admin/Model/User.php
+++ app/code/core/Mage/Admin/Model/User.php
@@ -74,14 +74,25 @@ class Mage_Admin_Model_User extends Mage_Core_Model_Abstract
 
     /**
      * Minimum length of admin password
+     * @deprecated Use getMinAdminPasswordLength() method instead
      */
-    const MIN_PASSWORD_LENGTH = 7;
+    const MIN_PASSWORD_LENGTH = 14;
+
+    /**
+     * Configuration path for minimum length of admin password
+     */
+    const XML_PATH_MIN_ADMIN_PASSWORD_LENGTH = 'admin/security/min_admin_password_length';
 
     /**
      * Length of salt
      */
     const HASH_SALT_LENGTH = 32;
 
+    /**
+     * Empty hash salt
+     */
+    const HASH_SALT_EMPTY = null;
+
     /**
      * Model event prefix
      *
@@ -452,7 +463,7 @@ class Mage_Admin_Model_User extends Mage_Core_Model_Abstract
      */
     protected function _getEncodedPassword($password)
     {
-        return $this->_getHelper('core')->getHash($password, self::HASH_SALT_LENGTH);
+        return $this->_getHelper('core')->getHashPassword($password, self::HASH_SALT_LENGTH);
     }
 
     /**
@@ -562,17 +573,23 @@ class Mage_Admin_Model_User extends Mage_Core_Model_Abstract
         }
 
         if ($this->hasNewPassword()) {
-            if (Mage::helper('core/string')->strlen($this->getNewPassword()) < self::MIN_PASSWORD_LENGTH) {
-                $errors[] = Mage::helper('adminhtml')->__('Password must be at least of %d characters.', self::MIN_PASSWORD_LENGTH);
+            $password = $this->getNewPassword();
+        } elseif ($this->hasPassword()) {
+            $password = $this->getPassword();
+        }
+        if (isset($password)) {
+            $minAdminPasswordLength = $this->getMinAdminPasswordLength();
+            if (Mage::helper('core/string')->strlen($password) < $minAdminPasswordLength) {
+                $errors[] = Mage::helper('adminhtml')
+                    ->__('Password must be at least of %d characters.', $minAdminPasswordLength);
             }
 
-            if (!preg_match('/[a-z]/iu', $this->getNewPassword())
-                || !preg_match('/[0-9]/u', $this->getNewPassword())
-            ) {
-                $errors[] = Mage::helper('adminhtml')->__('Password must include both numeric and alphabetic characters.');
+            if (!preg_match('/[a-z]/iu', $password) || !preg_match('/[0-9]/u', $password)) {
+                $errors[] = Mage::helper('adminhtml')
+                    ->__('Password must include both numeric and alphabetic characters.');
             }
 
-            if ($this->hasPasswordConfirmation() && $this->getNewPassword() != $this->getPasswordConfirmation()) {
+            if ($this->hasPasswordConfirmation() && $password != $this->getPasswordConfirmation()) {
                 $errors[] = Mage::helper('adminhtml')->__('Password confirmation must be same as password.');
             }
 
@@ -691,4 +708,16 @@ class Mage_Admin_Model_User extends Mage_Core_Model_Abstract
         $emails = str_replace(' ', '', Mage::getStoreConfig(self::XML_PATH_ADDITIONAL_EMAILS));
         return explode(',', $emails);
     }
+
+    /**
+     * Retrieve minimum length of admin password
+     *
+     * @return int
+     */
+    public function getMinAdminPasswordLength()
+    {
+        $minLength = (int)Mage::getStoreConfig(self::XML_PATH_MIN_ADMIN_PASSWORD_LENGTH);
+        $absoluteMinLength = Mage_Core_Model_App::ABSOLUTE_MIN_PASSWORD_LENGTH;
+        return ($minLength < $absoluteMinLength) ? $absoluteMinLength : $minLength;
+    }
 }
diff --git app/code/core/Mage/Admin/etc/config.xml app/code/core/Mage/Admin/etc/config.xml
index 27e1d0b272b..04ba2a46907 100644
--- app/code/core/Mage/Admin/etc/config.xml
+++ app/code/core/Mage/Admin/etc/config.xml
@@ -28,7 +28,7 @@
 <config>
     <modules>
         <Mage_Admin>
-            <version>1.6.1.2</version>
+            <version>1.6.1.3</version>
         </Mage_Admin>
     </modules>
     <global>
diff --git app/code/core/Mage/Admin/sql/admin_setup/upgrade-1.6.1.2-1.6.1.3.php app/code/core/Mage/Admin/sql/admin_setup/upgrade-1.6.1.2-1.6.1.3.php
new file mode 100644
index 00000000000..9c5a6cdf4cc
--- /dev/null
+++ app/code/core/Mage/Admin/sql/admin_setup/upgrade-1.6.1.2-1.6.1.3.php
@@ -0,0 +1,43 @@
+<?php
+/**
+ * Magento
+ *
+ * NOTICE OF LICENSE
+ *
+ * This source file is subject to the Open Software License (OSL 3.0)
+ * that is bundled with this package in the file LICENSE.txt.
+ * It is also available through the world-wide-web at this URL:
+ * http://opensource.org/licenses/osl-3.0.php
+ * If you did not receive a copy of the license and are unable to
+ * obtain it through the world-wide-web, please send an email
+ * to license@magento.com so we can send you a copy immediately.
+ *
+ * DISCLAIMER
+ *
+ * Do not edit or add to this file if you wish to upgrade Magento to newer
+ * versions in the future. If you wish to customize Magento for your
+ * needs please refer to http://www.magento.com for more information.
+ *
+ * @category    Mage
+ * @package     Mage_Admin
+ * @copyright  Copyright (c) 2006-2019 Magento, Inc. (http://www.magento.com)
+ * @license    http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
+ */
+
+/** @var $installer Mage_Core_Model_Resource_Setup */
+$installer = $this;
+$installer->startSetup();
+
+//Increase password field length
+$installer->getConnection()->changeColumn(
+    $installer->getTable('admin/user'),
+    'password',
+    'password',
+    array(
+        'type' => Varien_Db_Ddl_Table::TYPE_TEXT,
+        'length' => 255,
+        'comment' => 'User Password',
+    )
+);
+
+$installer->endSetup();
diff --git app/code/core/Mage/Adminhtml/Block/Api/User/Edit/Tab/Main.php app/code/core/Mage/Adminhtml/Block/Api/User/Edit/Tab/Main.php
index 43c1fd46e28..1ec108f8a74 100644
--- app/code/core/Mage/Adminhtml/Block/Api/User/Edit/Tab/Main.php
+++ app/code/core/Mage/Adminhtml/Block/Api/User/Edit/Tab/Main.php
@@ -88,13 +88,16 @@ class Mage_Adminhtml_Block_Api_User_Edit_Tab_Main extends Mage_Adminhtml_Block_W
             'required' => true,
         ));
 
+        $minPasswordLength = Mage::getModel('customer/customer')->getMinPasswordLength();
         if ($model->getUserId()) {
             $fieldset->addField('password', 'password', array(
                 'name'  => 'new_api_key',
                 'label' => Mage::helper('adminhtml')->__('New API Key'),
                 'id'    => 'new_pass',
                 'title' => Mage::helper('adminhtml')->__('New API Key'),
-                'class' => 'input-text validate-password',
+                'class' => 'input-text validate-password min-pass-length-' . $minPasswordLength,
+                'note' => Mage::helper('adminhtml')
+                    ->__('API Key must be at least of %d characters.', $minPasswordLength),
             ));
 
             $fieldset->addField('confirmation', 'password', array(
@@ -105,15 +108,17 @@ class Mage_Adminhtml_Block_Api_User_Edit_Tab_Main extends Mage_Adminhtml_Block_W
             ));
         }
         else {
-           $fieldset->addField('password', 'password', array(
+            $fieldset->addField('password', 'password', array(
                 'name'  => 'api_key',
                 'label' => Mage::helper('adminhtml')->__('API Key'),
                 'id'    => 'customer_pass',
                 'title' => Mage::helper('adminhtml')->__('API Key'),
-                'class' => 'input-text required-entry validate-password',
+                'class' => 'input-text required-entry validate-password min-pass-length-' . $minPasswordLength,
                 'required' => true,
+                'note' => Mage::helper('adminhtml')
+                    ->__('API Key must be at least of %d characters.', $minPasswordLength),
             ));
-           $fieldset->addField('confirmation', 'password', array(
+            $fieldset->addField('confirmation', 'password', array(
                 'name'  => 'api_key_confirmation',
                 'label' => Mage::helper('adminhtml')->__('API Key Confirmation'),
                 'id'    => 'confirmation',
diff --git app/code/core/Mage/Adminhtml/Block/Catalog/Product/Attribute/Set/Main.php app/code/core/Mage/Adminhtml/Block/Catalog/Product/Attribute/Set/Main.php
index 7fd715d671e..afa0af3a545 100644
--- app/code/core/Mage/Adminhtml/Block/Catalog/Product/Attribute/Set/Main.php
+++ app/code/core/Mage/Adminhtml/Block/Catalog/Product/Attribute/Set/Main.php
@@ -93,10 +93,13 @@ class Mage_Adminhtml_Block_Catalog_Product_Attribute_Set_Main extends Mage_Admin
                 'class'     => 'save'
         )));
 
+        $deleteConfirmMessage = $this->jsQuoteEscape(Mage::helper('catalog')
+            ->__('All products of this set will be deleted! Are you sure you want to delete this attribute set?'));
+        $deleteUrl = $this->getUrlSecure('*/*/delete', array('id' => $setId));
         $this->setChild('delete_button',
             $this->getLayout()->createBlock('adminhtml/widget_button')->setData(array(
                 'label'     => Mage::helper('catalog')->__('Delete Attribute Set'),
-                'onclick'   => 'deleteConfirm(\''. $this->jsQuoteEscape(Mage::helper('catalog')->__('All products of this set will be deleted! Are you sure you want to delete this attribute set?')) . '\', \'' . $this->getUrl('*/*/delete', array('id' => $setId)) . '\')',
+                'onclick'   => 'deleteConfirm(\'' . $deleteConfirmMessage . '\', \'' . $deleteUrl . '\')',
                 'class'     => 'delete'
         )));
 
diff --git app/code/core/Mage/Adminhtml/Block/Customer/Edit/Renderer/Newpass.php app/code/core/Mage/Adminhtml/Block/Customer/Edit/Renderer/Newpass.php
index 33a634dff68..ed7d45a3c8c 100644
--- app/code/core/Mage/Adminhtml/Block/Customer/Edit/Renderer/Newpass.php
+++ app/code/core/Mage/Adminhtml/Block/Customer/Edit/Renderer/Newpass.php
@@ -45,7 +45,11 @@ class Mage_Adminhtml_Block_Customer_Edit_Renderer_Newpass
     {
         $html  = '<tr>';
         $html .= '<td class="label">' . $element->getLabelHtml() . '</td>';
-        $html .= '<td class="value">' . $element->getElementHtml() . '</td>';
+        $html .= '<td class="value">' . $element->getElementHtml();
+        if ($element->getNote()) {
+            $html .= '<p class="note"><span>' . $element->getNote() . '</span></p>';
+        }
+        $html .= '</td>';
         $html .= '</tr>' . "\n";
         $html .= '<tr>';
         $html .= '<td class="label"><label>&nbsp;</label></td>';
diff --git app/code/core/Mage/Adminhtml/Block/Customer/Edit/Tab/Account.php app/code/core/Mage/Adminhtml/Block/Customer/Edit/Tab/Account.php
index 0a87963993a..27d8d97f0f0 100644
--- app/code/core/Mage/Adminhtml/Block/Customer/Edit/Tab/Account.php
+++ app/code/core/Mage/Adminhtml/Block/Customer/Edit/Tab/Account.php
@@ -80,8 +80,12 @@ class Mage_Adminhtml_Block_Customer_Edit_Tab_Account extends Mage_Adminhtml_Bloc
             ->setDisableAutoGroupChangeAttributeValue($customer->getData($disableAutoGroupChangeAttributeName)));
 
         if ($customer->getId()) {
-            $form->getElement('website_id')->setDisabled('disabled');
-            $form->getElement('created_in')->setDisabled('disabled');
+            if ($element = $form->getElement('website_id')) {
+                $element->setDisabled('disabled');
+            }
+            if ($element = $form->getElement('created_in')) {
+                $element->setDisabled('disabled');
+            }
         } else {
             $fieldset->removeField('created_in');
             $form->getElement('website_id')->addClass('validate-website-has-store');
@@ -161,6 +165,7 @@ class Mage_Adminhtml_Block_Customer_Edit_Tab_Account extends Mage_Adminhtml_Bloc
             }
         }
 
+        $minPasswordLength = Mage::getModel('customer/customer')->getMinPasswordLength();
         if ($customer->getId()) {
             if (!$customer->isReadonly()) {
                 // Add password management fieldset
@@ -173,7 +178,9 @@ class Mage_Adminhtml_Block_Customer_Edit_Tab_Account extends Mage_Adminhtml_Bloc
                     array(
                         'label' => Mage::helper('customer')->__('New Password'),
                         'name'  => 'new_password',
-                        'class' => 'validate-new-password'
+                        'class' => 'validate-new-password min-pass-length-' . $minPasswordLength,
+                        'note' => Mage::helper('adminhtml')
+                            ->__('Password must be at least of %d characters.', $minPasswordLength),
                     )
                 );
                 $field->setRenderer($this->getLayout()->createBlock('adminhtml/customer_edit_renderer_newpass'));
@@ -210,9 +217,11 @@ class Mage_Adminhtml_Block_Customer_Edit_Tab_Account extends Mage_Adminhtml_Bloc
             $field = $newFieldset->addField('password', 'text',
                 array(
                     'label' => Mage::helper('customer')->__('Password'),
-                    'class' => 'input-text required-entry validate-password',
+                    'class' => 'input-text required-entry validate-password min-pass-length-' . $minPasswordLength,
                     'name'  => 'password',
-                    'required' => true
+                    'required' => true,
+                    'note' => Mage::helper('adminhtml')
+                        ->__('Password must be at least of %d characters.', $minPasswordLength),
                 )
             );
             $field->setRenderer($this->getLayout()->createBlock('adminhtml/customer_edit_renderer_newpass'));
diff --git app/code/core/Mage/Adminhtml/Block/Newsletter/Queue/Preview.php app/code/core/Mage/Adminhtml/Block/Newsletter/Queue/Preview.php
index f36054a3af5..7bfd589f1e2 100644
--- app/code/core/Mage/Adminhtml/Block/Newsletter/Queue/Preview.php
+++ app/code/core/Mage/Adminhtml/Block/Newsletter/Queue/Preview.php
@@ -76,6 +76,9 @@ class Mage_Adminhtml_Block_Newsletter_Queue_Preview extends Mage_Adminhtml_Block
             $templateProcessed = "<pre>" . htmlspecialchars($templateProcessed) . "</pre>";
         }
 
+        $templateProcessed = Mage::getSingleton('core/input_filter_maliciousCode')
+            ->linkFilter($templateProcessed);
+
         Varien_Profiler::stop("newsletter_queue_proccessing");
 
         return $templateProcessed;
diff --git app/code/core/Mage/Adminhtml/Block/Newsletter/Template/Edit.php app/code/core/Mage/Adminhtml/Block/Newsletter/Template/Edit.php
index 55f22db44aa..45d90dd22c7 100644
--- app/code/core/Mage/Adminhtml/Block/Newsletter/Template/Edit.php
+++ app/code/core/Mage/Adminhtml/Block/Newsletter/Template/Edit.php
@@ -315,7 +315,7 @@ class Mage_Adminhtml_Block_Newsletter_Template_Edit extends Mage_Adminhtml_Block
      */
     public function getDeleteUrl()
     {
-        return $this->getUrl('*/*/delete', array('id' => $this->getRequest()->getParam('id')));
+        return $this->getUrlSecure('*/*/delete', array('id' => $this->getRequest()->getParam('id')));
     }
 
     /**
diff --git app/code/core/Mage/Adminhtml/Block/Newsletter/Template/Preview.php app/code/core/Mage/Adminhtml/Block/Newsletter/Template/Preview.php
index f0c3b1ce983..48d56077280 100644
--- app/code/core/Mage/Adminhtml/Block/Newsletter/Template/Preview.php
+++ app/code/core/Mage/Adminhtml/Block/Newsletter/Template/Preview.php
@@ -74,6 +74,9 @@ class Mage_Adminhtml_Block_Newsletter_Template_Preview extends Mage_Adminhtml_Bl
             $templateProcessed = "<pre>" . htmlspecialchars($templateProcessed) . "</pre>";
         }
 
+        $templateProcessed = Mage::getSingleton('core/input_filter_maliciousCode')
+            ->linkFilter($templateProcessed);
+
         Varien_Profiler::stop("newsletter_template_proccessing");
 
         return $templateProcessed;
diff --git app/code/core/Mage/Adminhtml/Block/Permissions/Tab/Useredit.php app/code/core/Mage/Adminhtml/Block/Permissions/Tab/Useredit.php
index 86bb033588f..39a0cb579e3 100644
--- app/code/core/Mage/Adminhtml/Block/Permissions/Tab/Useredit.php
+++ app/code/core/Mage/Adminhtml/Block/Permissions/Tab/Useredit.php
@@ -85,6 +85,7 @@ class Mage_Adminhtml_Block_Permissions_Tab_Useredit extends Mage_Adminhtml_Block
             )
         );
 
+        $minPasswordLength = Mage::getModel('customer/customer')->getMinPasswordLength();
         if ($user->getUserId()) {
             $fieldset->addField('password', 'password',
                 array(
@@ -92,7 +93,9 @@ class Mage_Adminhtml_Block_Permissions_Tab_Useredit extends Mage_Adminhtml_Block
                     'label' => Mage::helper('adminhtml')->__('New Password'),
                     'id'    => 'new_pass',
                     'title' => Mage::helper('adminhtml')->__('New Password'),
-                    'class' => 'input-text validate-password',
+                    'class' => 'input-text validate-password min-pass-length-' . $minPasswordLength,
+                    'note' => Mage::helper('adminhtml')
+                        ->__('Password must be at least of %d characters.', $minPasswordLength),
                 )
             );
 
@@ -112,8 +115,10 @@ class Mage_Adminhtml_Block_Permissions_Tab_Useredit extends Mage_Adminhtml_Block
                     'label' => Mage::helper('adminhtml')->__('Password'),
                     'id'    => 'customer_pass',
                     'title' => Mage::helper('adminhtml')->__('Password'),
-                    'class' => 'input-text required-entry validate-password',
+                    'class' => 'input-text required-entry validate-password min-pass-length-' . $minPasswordLength,
                     'required' => true,
+                    'note' => Mage::helper('adminhtml')
+                        ->__('Password must be at least of %d characters.', $minPasswordLength),
                 )
             );
            $fieldset->addField('confirmation', 'password',
diff --git app/code/core/Mage/Adminhtml/Block/Permissions/User/Edit/Tab/Main.php app/code/core/Mage/Adminhtml/Block/Permissions/User/Edit/Tab/Main.php
index c3273267a8f..650b61f23b8 100644
--- app/code/core/Mage/Adminhtml/Block/Permissions/User/Edit/Tab/Main.php
+++ app/code/core/Mage/Adminhtml/Block/Permissions/User/Edit/Tab/Main.php
@@ -88,13 +88,16 @@ class Mage_Adminhtml_Block_Permissions_User_Edit_Tab_Main extends Mage_Adminhtml
             'required' => true,
         ));
 
+        $minAdminPasswordLength = Mage::getModel('admin/user')->getMinAdminPasswordLength();
         if ($model->getUserId()) {
             $fieldset->addField('password', 'password', array(
                 'name'  => 'new_password',
                 'label' => Mage::helper('adminhtml')->__('New Password'),
                 'id'    => 'new_pass',
                 'title' => Mage::helper('adminhtml')->__('New Password'),
-                'class' => 'input-text validate-admin-password',
+                'class' => 'input-text validate-admin-password min-admin-pass-length-' . $minAdminPasswordLength,
+                'note' => Mage::helper('adminhtml')
+                    ->__('Password must be at least of %d characters.', $minAdminPasswordLength),
             ));
 
             $fieldset->addField('confirmation', 'password', array(
@@ -105,15 +108,18 @@ class Mage_Adminhtml_Block_Permissions_User_Edit_Tab_Main extends Mage_Adminhtml
             ));
         }
         else {
-           $fieldset->addField('password', 'password', array(
+            $fieldset->addField('password', 'password', array(
                 'name'  => 'password',
                 'label' => Mage::helper('adminhtml')->__('Password'),
                 'id'    => 'customer_pass',
                 'title' => Mage::helper('adminhtml')->__('Password'),
-                'class' => 'input-text required-entry validate-admin-password',
+                'class' => 'input-text required-entry validate-admin-password min-admin-pass-length-'
+                    . $minAdminPasswordLength,
                 'required' => true,
+                'note' => Mage::helper('adminhtml')
+                    ->__('Password must be at least of %d characters.', $minAdminPasswordLength),
             ));
-           $fieldset->addField('confirmation', 'password', array(
+            $fieldset->addField('confirmation', 'password', array(
                 'name'  => 'password_confirmation',
                 'label' => Mage::helper('adminhtml')->__('Password Confirmation'),
                 'id'    => 'confirmation',
diff --git app/code/core/Mage/Adminhtml/Block/Sales/Order/View.php app/code/core/Mage/Adminhtml/Block/Sales/Order/View.php
index 722edeecd86..c7d232cac82 100644
--- app/code/core/Mage/Adminhtml/Block/Sales/Order/View.php
+++ app/code/core/Mage/Adminhtml/Block/Sales/Order/View.php
@@ -226,7 +226,7 @@ class Mage_Adminhtml_Block_Sales_Order_View extends Mage_Adminhtml_Block_Widget_
 
     public function getCancelUrl()
     {
-        return $this->getUrl('*/*/cancel');
+        return $this->getUrlSecure('*/*/cancel');
     }
 
     public function getInvoiceUrl()
diff --git app/code/core/Mage/Adminhtml/Block/System/Account/Edit/Form.php app/code/core/Mage/Adminhtml/Block/System/Account/Edit/Form.php
index 7aebc35ec0f..8e6660d7545 100644
--- app/code/core/Mage/Adminhtml/Block/System/Account/Edit/Form.php
+++ app/code/core/Mage/Adminhtml/Block/System/Account/Edit/Form.php
@@ -82,11 +82,14 @@ class Mage_Adminhtml_Block_System_Account_Edit_Form extends Mage_Adminhtml_Block
             )
         );
 
+        $minAdminPasswordLength = Mage::getModel('admin/user')->getMinAdminPasswordLength();
         $fieldset->addField('password', 'password', array(
                 'name'  => 'new_password',
                 'label' => Mage::helper('adminhtml')->__('New Password'),
                 'title' => Mage::helper('adminhtml')->__('New Password'),
-                'class' => 'input-text validate-admin-password',
+                'class' => 'input-text validate-admin-password min-admin-pass-length-' . $minAdminPasswordLength,
+                'note' => Mage::helper('adminhtml')
+                    ->__('Password must be at least of %d characters.', $minAdminPasswordLength),
             )
         );
 
diff --git app/code/core/Mage/Adminhtml/Block/System/Email/Template/Edit.php app/code/core/Mage/Adminhtml/Block/System/Email/Template/Edit.php
index 55b6bedb47c..9683f4f0aea 100644
--- app/code/core/Mage/Adminhtml/Block/System/Email/Template/Edit.php
+++ app/code/core/Mage/Adminhtml/Block/System/Email/Template/Edit.php
@@ -267,7 +267,7 @@ class Mage_Adminhtml_Block_System_Email_Template_Edit extends Mage_Adminhtml_Blo
      */
     public function getDeleteUrl()
     {
-        return $this->getUrl('*/*/delete', array('_current' => true));
+        return $this->getUrlSecure('*/*/delete', array('_current' => true));
     }
 
     /**
diff --git app/code/core/Mage/Adminhtml/Block/Widget/Grid.php app/code/core/Mage/Adminhtml/Block/Widget/Grid.php
index 1a902397771..fec89cef3dd 100644
--- app/code/core/Mage/Adminhtml/Block/Widget/Grid.php
+++ app/code/core/Mage/Adminhtml/Block/Widget/Grid.php
@@ -464,7 +464,7 @@ class Mage_Adminhtml_Block_Widget_Grid extends Mage_Adminhtml_Block_Widget
     {
         if ($this->getCollection()) {
             $field = ( $column->getFilterIndex() ) ? $column->getFilterIndex() : $column->getIndex();
-            if ($column->getFilterConditionCallback()) {
+            if ($column->getFilterConditionCallback() && $column->getFilterConditionCallback()[0] instanceof self) {
                 call_user_func($column->getFilterConditionCallback(), $this->getCollection(), $column);
             } else {
                 $cond = $column->getFilter()->getCondition();
diff --git app/code/core/Mage/Adminhtml/Model/Config/Data.php app/code/core/Mage/Adminhtml/Model/Config/Data.php
index 4e9f6271317..dd27ae6fbcf 100644
--- app/code/core/Mage/Adminhtml/Model/Config/Data.php
+++ app/code/core/Mage/Adminhtml/Model/Config/Data.php
@@ -34,6 +34,10 @@
 
 class Mage_Adminhtml_Model_Config_Data extends Varien_Object
 {
+    const SCOPE_DEFAULT  = 'default';
+    const SCOPE_WEBSITES = 'websites';
+    const SCOPE_STORES   = 'stores';
+
     /**
      * Config data for sections
      *
@@ -268,15 +272,15 @@ class Mage_Adminhtml_Model_Config_Data extends Varien_Object
     protected function _getScope()
     {
         if ($this->getStore()) {
-            $scope   = 'stores';
+            $scope   = self::SCOPE_STORES;
             $scopeId = (int)Mage::getConfig()->getNode('stores/' . $this->getStore() . '/system/store/id');
             $scopeCode = $this->getStore();
         } elseif ($this->getWebsite()) {
-            $scope   = 'websites';
+            $scope   = self::SCOPE_WEBSITES;
             $scopeId = (int)Mage::getConfig()->getNode('websites/' . $this->getWebsite() . '/system/website/id');
             $scopeCode = $this->getWebsite();
         } else {
-            $scope   = 'default';
+            $scope   = self::SCOPE_DEFAULT;
             $scopeId = 0;
             $scopeCode = '';
         }
@@ -363,4 +367,100 @@ class Mage_Adminhtml_Model_Config_Data extends Varien_Object
         }
         return $this->_configRoot;
     }
+
+    /**
+     * Secure set groups
+     *
+     * @param array $groups
+     * @return Mage_Adminhtml_Model_Config_Data
+     * @throws Mage_Core_Exception
+     */
+    public function setGroupsSecure($groups)
+    {
+        $this->_validate();
+        $this->_getScope();
+
+        $groupsSecure = array();
+        $section = $this->getSection();
+        $sections = Mage::getModel('adminhtml/config')->getSections();
+
+        foreach ($groups as $group => $groupData) {
+            $groupConfig = $sections->descend($section . '/groups/' . $group);
+            foreach ($groupData['fields'] as $field => $fieldData) {
+                $fieldName = $field;
+                if ($groupConfig && $groupConfig->clone_fields) {
+                    if ($groupConfig->clone_model) {
+                        $cloneModel = Mage::getModel((string)$groupConfig->clone_model);
+                    } else {
+                        Mage::throwException(
+                            $this->__('Config form fieldset clone model required to be able to clone fields')
+                        );
+                    }
+                    foreach ($cloneModel->getPrefixes() as $prefix) {
+                        if (strpos($field, $prefix['field']) === 0) {
+                            $field = substr($field, strlen($prefix['field']));
+                        }
+                    }
+                }
+                $fieldConfig = $sections->descend($section . '/groups/' . $group . '/fields/' . $field);
+                if (!$fieldConfig) {
+                    $node = $sections->xpath($section . '//' . $group . '[@type="group"]/fields/' . $field);
+                    if ($node) {
+                        $fieldConfig = $node[0];
+                    }
+                }
+                if (($groupConfig ? !$groupConfig->dynamic_group : true) && !$this->_isValidField($fieldConfig)) {
+                    Mage::throwException(Mage::helper('adminhtml')->__('Wrong field specified.'));
+                }
+                $groupsSecure[$group]['fields'][$fieldName] = $fieldData;
+            }
+        }
+
+        $this->setGroups($groupsSecure);
+
+        return $this;
+    }
+
+    /**
+     * Check field visibility by scope
+     *
+     * @param Mage_Core_Model_Config_Element $field
+     * @return bool
+     */
+    protected function _isValidField($field)
+    {
+        if (!$field) {
+            return false;
+        }
+
+        switch ($this->getScope()) {
+            case self::SCOPE_DEFAULT:
+                return (bool)(int)$field->show_in_default;
+                break;
+            case self::SCOPE_WEBSITES:
+                return (bool)(int)$field->show_in_website;
+                break;
+            case self::SCOPE_STORES:
+                return (bool)(int)$field->show_in_store;
+                break;
+        }
+
+        return true;
+    }
+
+    /**
+     * Select group setter is secure or not based on the configuration
+     *
+     * @param array $groups
+     * @return Mage_Adminhtml_Model_Config_Data
+     * @throws Mage_Core_Exception
+     */
+    public function setGroupsSelector($groups)
+    {
+        if (Mage::getStoreConfigFlag('admin/security/secure_system_configuration_save_disabled')) {
+            return $this->setGroups($groups);
+        }
+
+        return $this->setGroupsSecure($groups);
+    }
 }
diff --git app/code/core/Mage/Adminhtml/Model/LayoutUpdate/Validator.php app/code/core/Mage/Adminhtml/Model/LayoutUpdate/Validator.php
index 817e6c7b8a0..a7709d17aab 100644
--- app/code/core/Mage/Adminhtml/Model/LayoutUpdate/Validator.php
+++ app/code/core/Mage/Adminhtml/Model/LayoutUpdate/Validator.php
@@ -53,33 +53,26 @@ class Mage_Adminhtml_Model_LayoutUpdate_Validator extends Zend_Validate_Abstract
      *
      * @var array
      */
-    protected $_disallowedXPathExpressions = array(
-        '*//template',
-        '*//@template',
-        '//*[@method=\'setTemplate\']',
-        '//*[@method=\'setDataUsingMethod\']//*[contains(translate(text(),
-        \'ABCDEFGHIJKLMNOPQRSTUVWXYZ\', \'abcdefghijklmnopqrstuvwxyz\'), \'template\')]/../*',
-    );
+    protected $_disallowedXPathExpressions = array();
 
     /**
      * Disallowed template name
      *
      * @var array
      */
-    protected $_disallowedBlock = array(
-        'Mage_Install_Block_End',
-        'Mage_Rss_Block_Order_New',
-        'Mage_Core_Block_Template_Zend',
-    );
+    protected $_disallowedBlock = array();
+
+    /**
+     * @var Mage_Core_Model_Layout_Validator
+     */
+    protected $_validator;
 
     /**
      * Protected expressions
      *
      * @var array
      */
-    protected $_protectedExpressions = array(
-        self::PROTECTED_ATTR_HELPER_IN_TAG_ACTION_VAR => '//action/*[@helper]',
-    );
+    protected $_protectedExpressions = array();
 
     /**
      * Construct
@@ -87,27 +80,17 @@ class Mage_Adminhtml_Model_LayoutUpdate_Validator extends Zend_Validate_Abstract
     public function __construct()
     {
         $this->_initMessageTemplates();
+        $this->_initValidator();
     }
 
     /**
-     * Initialize messages templates with translating
+     * Returns array of validation failure messages
      *
-     * @return Mage_Adminhtml_Model_LayoutUpdate_Validator
+     * @return array
      */
-    protected function _initMessageTemplates()
+    public function getMessages()
     {
-        if (!$this->_messageTemplates) {
-            $this->_messageTemplates = array(
-                self::PROTECTED_ATTR_HELPER_IN_TAG_ACTION_VAR =>
-                    Mage::helper('adminhtml')->__('Helper attributes should not be used in custom layout updates.'),
-                self::XML_INVALID => Mage::helper('adminhtml')->__('XML data is invalid.'),
-                self::INVALID_TEMPLATE_PATH => Mage::helper('adminhtml')->__(
-                    'Invalid template path used in layout update.'
-                ),
-                self::INVALID_BLOCK_NAME => Mage::helper('adminhtml')->__('Disallowed block name for frontend.'),
-            );
-        }
-        return $this;
+        return $this->_validator->getMessages();
     }
 
     /**
@@ -124,43 +107,42 @@ class Mage_Adminhtml_Model_LayoutUpdate_Validator extends Zend_Validate_Abstract
      */
     public function isValid($value)
     {
-        if (is_string($value)) {
-            $value = trim($value);
-            try {
-                //wrap XML value in the "config" tag because config cannot
-                //contain multiple root tags
-                $value = new Varien_Simplexml_Element('<config>' . $value . '</config>');
-            } catch (Exception $e) {
-                $this->_error(self::XML_INVALID);
-                return false;
-            }
-        } elseif (!($value instanceof Varien_Simplexml_Element)) {
-            throw new Exception(
-                Mage::helper('adminhtml')->__('XML object is not instance of "Varien_Simplexml_Element".'));
-        }
+        return $this->_validator->isValid($value);
+    }
 
-        if ($value->xpath($this->_getXpathBlockValidationExpression())) {
-            $this->_error(self::INVALID_BLOCK_NAME);
-            return false;
-        }
-        // if layout update declare custom templates then validate their paths
-        if ($templatePaths = $value->xpath($this->_getXpathValidationExpression())) {
-            try {
-                $this->_validateTemplatePath($templatePaths);
-            } catch (Exception $e) {
-                $this->_error(self::INVALID_TEMPLATE_PATH);
-                return false;
-            }
-        }
-        $this->_setValue($value);
+    /**
+     * Initialize the validator instance with populated template messages
+     */
+    protected function _initValidator()
+    {
+        $this->_validator = Mage::getModel('core/layout_validator');
+        $this->_disallowedBlock = $this->_validator->getDisallowedBlocks();
+        $this->_protectedExpressions = $this->_validator->getProtectedExpressions();
+        $this->_disallowedXPathExpressions = $this->_validator->getDisallowedXpathValidationExpression();
+        $this->_validator->setMessages($this->_messageTemplates);
+    }
 
-        foreach ($this->_protectedExpressions as $key => $xpr) {
-            if ($this->_value->xpath($xpr)) {
-                $this->_error($key);
-                return false;
-            }
+    /**
+     * Initialize messages templates with translating
+     *
+     * @return Mage_Adminhtml_Model_LayoutUpdate_Validator
+     */
+    protected function _initMessageTemplates()
+    {
+        if (!$this->_messageTemplates) {
+            $this->_messageTemplates = array(
+                self::PROTECTED_ATTR_HELPER_IN_TAG_ACTION_VAR =>
+                    Mage::helper('adminhtml')->__('Helper attributes should not be used in custom layout updates.'),
+                self::XML_INVALID => Mage::helper('adminhtml')->__('XML data is invalid.'),
+                self::INVALID_TEMPLATE_PATH => Mage::helper('adminhtml')->__(
+                    'Invalid template path used in layout update.'
+                ),
+                Mage_Core_Model_Layout_Validator::INVALID_BLOCK_NAME => Mage::helper('adminhtml')->__('Disallowed block name for frontend.'),
+                Mage_Core_Model_Layout_Validator::INVALID_XML_OBJECT_EXCEPTION =>
+                    Mage::helper('adminhtml')->__('XML object is not instance of "Varien_Simplexml_Element".'),
+            );
         }
-        return true;
+        return $this;
     }
 
     /**
@@ -168,8 +150,9 @@ class Mage_Adminhtml_Model_LayoutUpdate_Validator extends Zend_Validate_Abstract
      *
      * @return string xPath for validate incorrect path to template
      */
-    protected function _getXpathValidationExpression() {
-        return implode(" | ", $this->_disallowedXPathExpressions);
+    protected function _getXpathValidationExpression()
+    {
+        return $this->_validator->getXpathValidationExpression();
     }
 
     /**
@@ -177,16 +160,9 @@ class Mage_Adminhtml_Model_LayoutUpdate_Validator extends Zend_Validate_Abstract
      *
      * @return string xPath for validate incorrect block name
      */
-    protected function _getXpathBlockValidationExpression() {
-        $xpath = "";
-        if (count($this->_disallowedBlock)) {
-            foreach ($this->_disallowedBlock as $key => $value) {
-                $xpath .= $key > 0 ? " | " : '';
-                $xpath .= "//block[translate(@type, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = ";
-                $xpath .= "translate('$value', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')]";
-            }
-        }
-        return $xpath;
+    protected function _getXpathBlockValidationExpression()
+    {
+        return $this->_validator->getXpathBlockValidationExpression();
     }
 
     /**
@@ -197,14 +173,6 @@ class Mage_Adminhtml_Model_LayoutUpdate_Validator extends Zend_Validate_Abstract
      */
     protected function _validateTemplatePath(array $templatePaths)
     {
-        /**@var $path Varien_Simplexml_Element */
-        foreach ($templatePaths as $path) {
-            if ($path->hasChildren()) {
-                $path = stripcslashes(trim((string) $path->children(), '"'));
-            }
-            if (strpos($path, '..' . DS) !== false) {
-                throw new Exception();
-            }
-        }
+        $this->_validator->validateTemplatePath($templatePaths);
     }
 }
diff --git app/code/core/Mage/Adminhtml/Model/System/Config/Backend/Locale.php app/code/core/Mage/Adminhtml/Model/System/Config/Backend/Locale.php
index ecebe0abeb3..df9a563f94c 100644
--- app/code/core/Mage/Adminhtml/Model/System/Config/Backend/Locale.php
+++ app/code/core/Mage/Adminhtml/Model/System/Config/Backend/Locale.php
@@ -45,6 +45,39 @@ class Mage_Adminhtml_Model_System_Config_Backend_Locale extends Mage_Core_Model_
         $allCurrenciesOptions = Mage::getSingleton('adminhtml/system_config_source_locale_currency_all')
             ->toOptionArray(true);
 
+        if (!function_exists('array_column')) {
+            function array_column(array $allCurrenciesOptions, $columnKey, $indexKey = null)
+            {
+                $array = array();
+                foreach ($allCurrenciesOptions as $allCurrenciesOption) {
+                    if (!array_key_exists($columnKey, $allCurrenciesOption)) {
+                        Mage::getSingleton('adminhtml/session')->addError(
+                            Mage::helper('adminhtml')->__("Key %s does not exist in array", $columnKey)
+                        );
+                        return false;
+                    }
+                    if (is_null($indexKey)) {
+                        $array[] = $allCurrenciesOption[$columnKey];
+                    } else {
+                        if (!array_key_exists($indexKey, $allCurrenciesOption)) {
+                            Mage::getSingleton('adminhtml/session')->addError(
+                                Mage::helper('adminhtml')->__("Key %s does not exist in array", $indexKey)
+                            );
+                            return false;
+                        }
+                        if (!is_scalar($allCurrenciesOption[$indexKey])) {
+                            Mage::getSingleton('adminhtml/session')->addError(
+                                Mage::helper('adminhtml')->__("Key %s does not contain scalar value", $indexKey)
+                            );
+                            return false;
+                        }
+                        $array[$allCurrenciesOption[$indexKey]] = $allCurrenciesOption[$columnKey];
+                    }
+                }
+                return $array;
+            }
+        }
+
         $allCurrenciesValues = array_column($allCurrenciesOptions, 'value');
 
         foreach ($this->getValue() as $currency) {
diff --git app/code/core/Mage/Adminhtml/Model/System/Config/Backend/Passwordlength.php app/code/core/Mage/Adminhtml/Model/System/Config/Backend/Passwordlength.php
new file mode 100644
index 00000000000..a2793373a80
--- /dev/null
+++ app/code/core/Mage/Adminhtml/Model/System/Config/Backend/Passwordlength.php
@@ -0,0 +1,50 @@
+<?php
+/**
+ * Magento
+ *
+ * NOTICE OF LICENSE
+ *
+ * This source file is subject to the Open Software License (OSL 3.0)
+ * that is bundled with this package in the file LICENSE.txt.
+ * It is also available through the world-wide-web at this URL:
+ * http://opensource.org/licenses/osl-3.0.php
+ * If you did not receive a copy of the license and are unable to
+ * obtain it through the world-wide-web, please send an email
+ * to license@magento.com so we can send you a copy immediately.
+ *
+ * DISCLAIMER
+ *
+ * Do not edit or add to this file if you wish to upgrade Magento to newer
+ * versions in the future. If you wish to customize Magento for your
+ * needs please refer to http://www.magento.com for more information.
+ *
+ * @category    Mage
+ * @package     Mage_Adminhtml
+ * @copyright  Copyright (c) 2006-2019 Magento, Inc. (http://www.magento.com)
+ * @license    http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
+ */
+
+/**
+ * Password length config field backend model
+ *
+ * @category    Mage
+ * @package     Mage_Adminhtml
+ * @author      Magento Core Team <core@magentocommerce.com>
+ */
+class Mage_Adminhtml_Model_System_Config_Backend_Passwordlength extends  Mage_Core_Model_Config_Data
+{
+    /**
+     * Before save processing
+     *
+     * @throws Mage_Core_Exception
+     * @return Mage_Adminhtml_Model_System_Config_Backend_Passwordlength
+     */
+    protected function _beforeSave()
+    {
+        if ((int)$this->getValue() < Mage_Core_Model_App::ABSOLUTE_MIN_PASSWORD_LENGTH) {
+            Mage::throwException(Mage::helper('adminhtml')
+                ->__('Password must be at least of %d characters.', Mage_Core_Model_App::ABSOLUTE_MIN_PASSWORD_LENGTH));
+        }
+        return $this;
+    }
+}
diff --git app/code/core/Mage/Adminhtml/controllers/Api/UserController.php app/code/core/Mage/Adminhtml/controllers/Api/UserController.php
index 92c034ed91f..097f4f7ae0d 100644
--- app/code/core/Mage/Adminhtml/controllers/Api/UserController.php
+++ app/code/core/Mage/Adminhtml/controllers/Api/UserController.php
@@ -111,6 +111,31 @@ class Mage_Adminhtml_Api_UserController extends Mage_Adminhtml_Controller_Action
                 return;
             }
             $model->setData($data);
+
+            if ($model->hasNewApiKey() && $model->getNewApiKey() === '') {
+                $model->unsNewApiKey();
+            }
+
+            if ($model->hasApiKeyConfirmation() && $model->getApiKeyConfirmation() === '') {
+                $model->unsApiKeyConfirmation();
+            }
+
+            $result = $model->validate();
+
+            if (is_array($result)) {
+                foreach ($result as $error) {
+                    $this->_getSession()->addError($error);
+                }
+                if ($id) {
+                    $this->_getSession()->setUserData($data);
+                    $this->_redirect('*/*/edit', array('user_id' => $id));
+                } else {
+                    $this->_getSession()->setUserData($data);
+                    $this->_redirect('*/*/new');
+                }
+                return;
+            }
+
             try {
                 $model->save();
                 if ( $uRoles = $this->getRequest()->getParam('roles', false) ) {
diff --git app/code/core/Mage/Adminhtml/controllers/Catalog/CategoryController.php app/code/core/Mage/Adminhtml/controllers/Catalog/CategoryController.php
index b9fb6c12c34..fb605d7c0d4 100644
--- app/code/core/Mage/Adminhtml/controllers/Catalog/CategoryController.php
+++ app/code/core/Mage/Adminhtml/controllers/Catalog/CategoryController.php
@@ -509,4 +509,15 @@ class Mage_Adminhtml_Catalog_CategoryController extends Mage_Adminhtml_Controlle
     {
         return Mage::getSingleton('admin/session')->isAllowed('catalog/categories');
     }
+
+    /**
+     * Controller predispatch method
+     *
+     * @return Mage_Adminhtml_Controller_Action
+     */
+    public function preDispatch()
+    {
+        $this->_setForcedFormKeyActions('delete');
+        return parent::preDispatch();
+    }
 }
diff --git app/code/core/Mage/Adminhtml/controllers/Catalog/Product/AttributeController.php app/code/core/Mage/Adminhtml/controllers/Catalog/Product/AttributeController.php
index 1dd32955328..88b8fc1b539 100644
--- app/code/core/Mage/Adminhtml/controllers/Catalog/Product/AttributeController.php
+++ app/code/core/Mage/Adminhtml/controllers/Catalog/Product/AttributeController.php
@@ -227,6 +227,7 @@ class Mage_Adminhtml_Catalog_Product_AttributeController extends Mage_Adminhtml_
                     return;
                 }
 
+                $data['backend_model'] = $model->getBackendModel();
                 $data['attribute_code'] = $model->getAttributeCode();
                 $data['is_user_defined'] = $model->getIsUserDefined();
                 $data['frontend_input'] = $model->getFrontendInput();
@@ -316,7 +317,7 @@ class Mage_Adminhtml_Catalog_Product_AttributeController extends Mage_Adminhtml_
 
             // entity type check
             $model->load($id);
-            if ($model->getEntityTypeId() != $this->_entityTypeId) {
+            if ($model->getEntityTypeId() != $this->_entityTypeId || !$model->getIsUserDefined()) {
                 Mage::getSingleton('adminhtml/session')->addError(
                     Mage::helper('catalog')->__('This attribute cannot be deleted.'));
                 $this->_redirect('*/*/');
diff --git app/code/core/Mage/Adminhtml/controllers/Catalog/Product/SetController.php app/code/core/Mage/Adminhtml/controllers/Catalog/Product/SetController.php
index 1333ddcb533..6becad10f58 100644
--- app/code/core/Mage/Adminhtml/controllers/Catalog/Product/SetController.php
+++ app/code/core/Mage/Adminhtml/controllers/Catalog/Product/SetController.php
@@ -208,6 +208,17 @@ class Mage_Adminhtml_Catalog_Product_SetController extends Mage_Adminhtml_Contro
         }
     }
 
+    /**
+     * Controller predispatch method
+     *
+     * @return Mage_Adminhtml_Controller_Action
+     */
+    public function preDispatch()
+    {
+        $this->_setForcedFormKeyActions('delete');
+        return parent::preDispatch();
+    }
+
     /**
      * Define in register catalog_product entity type code as entityType
      *
diff --git app/code/core/Mage/Adminhtml/controllers/Catalog/SearchController.php app/code/core/Mage/Adminhtml/controllers/Catalog/SearchController.php
index 961e9da9632..0a658308167 100644
--- app/code/core/Mage/Adminhtml/controllers/Catalog/SearchController.php
+++ app/code/core/Mage/Adminhtml/controllers/Catalog/SearchController.php
@@ -188,6 +188,17 @@ class Mage_Adminhtml_Catalog_SearchController extends Mage_Adminhtml_Controller_
         $this->_redirect('*/*/index');
     }
 
+    /**
+     * Controller predispatch method
+     *
+     * @return Mage_Adminhtml_Controller_Action
+     */
+    public function preDispatch()
+    {
+        $this->_setForcedFormKeyActions('delete', 'massDelete');
+        return parent::preDispatch();
+    }
+
     protected function _isAllowed()
     {
         return Mage::getSingleton('admin/session')->isAllowed('catalog/search');
diff --git app/code/core/Mage/Adminhtml/controllers/Cms/PageController.php app/code/core/Mage/Adminhtml/controllers/Cms/PageController.php
index aaeb253f068..c4409cf18fb 100644
--- app/code/core/Mage/Adminhtml/controllers/Cms/PageController.php
+++ app/code/core/Mage/Adminhtml/controllers/Cms/PageController.php
@@ -215,6 +215,17 @@ class Mage_Adminhtml_Cms_PageController extends Mage_Adminhtml_Controller_Action
         $this->_redirect('*/*/');
     }
 
+    /**
+     * Controller predispatch method
+     *
+     * @return Mage_Adminhtml_Controller_Action
+     */
+    public function preDispatch()
+    {
+        $this->_setForcedFormKeyActions('delete');
+        return parent::preDispatch();
+    }
+
     /**
      * Check the permission to run it
      *
diff --git app/code/core/Mage/Adminhtml/controllers/CustomerController.php app/code/core/Mage/Adminhtml/controllers/CustomerController.php
index 97ec81ea24e..8800701bce2 100644
--- app/code/core/Mage/Adminhtml/controllers/CustomerController.php
+++ app/code/core/Mage/Adminhtml/controllers/CustomerController.php
@@ -343,9 +343,15 @@ class Mage_Adminhtml_CustomerController extends Mage_Adminhtml_Controller_Action
                 }
 
                 if (!empty($data['account']['new_password'])) {
-                    $newPassword = $data['account']['new_password'];
+                    $newPassword = trim($data['account']['new_password']);
                     if ($newPassword == 'auto') {
                         $newPassword = $customer->generatePassword();
+                    } else {
+                        $minPasswordLength = Mage::getModel('customer/customer')->getMinPasswordLength();
+                        if (Mage::helper('core/string')->strlen($newPassword) < $minPasswordLength) {
+                            Mage::throwException(Mage::helper('customer')
+                                ->__('The minimum password length is %s', $minPasswordLength));
+                        }
                     }
                     $customer->changePassword($newPassword);
                     $customer->sendPasswordReminderEmail();
diff --git app/code/core/Mage/Adminhtml/controllers/IndexController.php app/code/core/Mage/Adminhtml/controllers/IndexController.php
index 8c12a155467..9551c5129ab 100644
--- app/code/core/Mage/Adminhtml/controllers/IndexController.php
+++ app/code/core/Mage/Adminhtml/controllers/IndexController.php
@@ -287,7 +287,8 @@ class Mage_Adminhtml_IndexController extends Mage_Adminhtml_Controller_Action
             $this->_validateResetPasswordLinkToken($userId, $resetPasswordLinkToken);
             $data = array(
                 'userId' => $userId,
-                'resetPasswordLinkToken' => $resetPasswordLinkToken
+                'resetPasswordLinkToken' => $resetPasswordLinkToken,
+                'minAdminPasswordLength' => Mage::getModel('admin/user')->getMinAdminPasswordLength()
             );
             $this->_outTemplate('resetforgottenpassword', $data);
         } catch (Exception $exception) {
@@ -342,7 +343,8 @@ class Mage_Adminhtml_IndexController extends Mage_Adminhtml_Controller_Action
             }
             $data = array(
                 'userId' => $userId,
-                'resetPasswordLinkToken' => $resetPasswordLinkToken
+                'resetPasswordLinkToken' => $resetPasswordLinkToken,
+                'minAdminPasswordLength' => Mage::getModel('admin/user')->getMinAdminPasswordLength()
             );
             $this->_outTemplate('resetforgottenpassword', $data);
             return;
@@ -360,7 +362,8 @@ class Mage_Adminhtml_IndexController extends Mage_Adminhtml_Controller_Action
             $this->_getSession()->addError($exception->getMessage());
             $data = array(
                 'userId' => $userId,
-                'resetPasswordLinkToken' => $resetPasswordLinkToken
+                'resetPasswordLinkToken' => $resetPasswordLinkToken,
+                'minAdminPasswordLength' => Mage::getModel('admin/user')->getMinAdminPasswordLength()
             );
             $this->_outTemplate('resetforgottenpassword', $data);
             return;
diff --git app/code/core/Mage/Adminhtml/controllers/Newsletter/TemplateController.php app/code/core/Mage/Adminhtml/controllers/Newsletter/TemplateController.php
index 6d22f4dec50..bf230a8c27e 100644
--- app/code/core/Mage/Adminhtml/controllers/Newsletter/TemplateController.php
+++ app/code/core/Mage/Adminhtml/controllers/Newsletter/TemplateController.php
@@ -249,4 +249,15 @@ class Mage_Adminhtml_Newsletter_TemplateController extends Mage_Adminhtml_Contro
         $this->getLayout()->getBlock('preview_form')->setFormData($data);
         $this->renderLayout();
     }
+
+    /**
+     * Controller predispatch method
+     *
+     * @return Mage_Adminhtml_Controller_Action
+     */
+    public function preDispatch()
+    {
+        $this->_setForcedFormKeyActions('delete');
+        return parent::preDispatch();
+    }
 }
diff --git app/code/core/Mage/Adminhtml/controllers/Permissions/BlockController.php app/code/core/Mage/Adminhtml/controllers/Permissions/BlockController.php
index eb91f850de1..97b81ea03ec 100644
--- app/code/core/Mage/Adminhtml/controllers/Permissions/BlockController.php
+++ app/code/core/Mage/Adminhtml/controllers/Permissions/BlockController.php
@@ -204,6 +204,17 @@ class Mage_Adminhtml_Permissions_BlockController extends Mage_Adminhtml_Controll
             );
     }
 
+    /**
+     * Controller predispatch method
+     *
+     * @return Mage_Adminhtml_Controller_Action
+     */
+    public function preDispatch()
+    {
+        $this->_setForcedFormKeyActions('delete');
+        return parent::preDispatch();
+    }
+
     /**
      * Check permissions before allow edit list of blocks
      *
diff --git app/code/core/Mage/Adminhtml/controllers/Sales/OrderController.php app/code/core/Mage/Adminhtml/controllers/Sales/OrderController.php
index c8ed25d07eb..9059239ec3f 100644
--- app/code/core/Mage/Adminhtml/controllers/Sales/OrderController.php
+++ app/code/core/Mage/Adminhtml/controllers/Sales/OrderController.php
@@ -778,4 +778,15 @@ class Mage_Adminhtml_Sales_OrderController extends Mage_Adminhtml_Controller_Act
             $this->_redirect('*/*/');
         }
     }
+
+    /**
+     * Controller predispatch method
+     *
+     * @return Mage_Adminhtml_Controller_Action
+     */
+    public function preDispatch()
+    {
+        $this->_setForcedFormKeyActions('cancel', 'massCancel');
+        return parent::preDispatch();
+    }
 }
diff --git app/code/core/Mage/Adminhtml/controllers/System/ConfigController.php app/code/core/Mage/Adminhtml/controllers/System/ConfigController.php
index b56b80f6ccc..60bf0cfe0c1 100644
--- app/code/core/Mage/Adminhtml/controllers/System/ConfigController.php
+++ app/code/core/Mage/Adminhtml/controllers/System/ConfigController.php
@@ -161,7 +161,7 @@ class Mage_Adminhtml_System_ConfigController extends Mage_Adminhtml_Controller_A
                 ->setSection($section)
                 ->setWebsite($website)
                 ->setStore($store)
-                ->setGroups($groups)
+                ->setGroupsSelector($groups)
                 ->save();
 
             // reinit configuration
diff --git app/code/core/Mage/Adminhtml/controllers/System/Email/TemplateController.php app/code/core/Mage/Adminhtml/controllers/System/Email/TemplateController.php
index 61b969e9a0d..11c7c2fac5d 100644
--- app/code/core/Mage/Adminhtml/controllers/System/Email/TemplateController.php
+++ app/code/core/Mage/Adminhtml/controllers/System/Email/TemplateController.php
@@ -129,7 +129,7 @@ class Mage_Adminhtml_System_Email_TemplateController extends Mage_Adminhtml_Cont
         }
 
         try {
-            $allowedHtmlTags = ['template_text', 'styles'];
+            $allowedHtmlTags = ['template_text', 'styles', 'variables'];
             if (Mage::helper('adminhtml')->hasTags($request->getParams(), $allowedHtmlTags)) {
                 Mage::throwException(Mage::helper('adminhtml')->__('Invalid template data.'));
             }
@@ -229,6 +229,17 @@ class Mage_Adminhtml_System_Email_TemplateController extends Mage_Adminhtml_Cont
         $this->getResponse()->setBody(Mage::helper('core')->jsonEncode($template->getData()));
     }
 
+    /**
+     * Controller predispatch method
+     *
+     * @return Mage_Adminhtml_Controller_Action
+     */
+    public function preDispatch()
+    {
+        $this->_setForcedFormKeyActions('delete');
+        return parent::preDispatch();
+    }
+
     /**
      * Load email template from request
      *
diff --git app/code/core/Mage/Adminhtml/controllers/Tax/RuleController.php app/code/core/Mage/Adminhtml/controllers/Tax/RuleController.php
index af5d7bd812e..aec7e038fa6 100644
--- app/code/core/Mage/Adminhtml/controllers/Tax/RuleController.php
+++ app/code/core/Mage/Adminhtml/controllers/Tax/RuleController.php
@@ -250,4 +250,15 @@ class Mage_Adminhtml_Tax_RuleController extends Mage_Adminhtml_Controller_Action
     {
         return Mage::helper($className);
     }
+
+    /**
+     * Controller predispatch method
+     *
+     * @return Mage_Adminhtml_Controller_Action
+     */
+    public function preDispatch()
+    {
+        $this->_setForcedFormKeyActions('delete');
+        return parent::preDispatch();
+    }
 }
diff --git app/code/core/Mage/Api/Model/User.php app/code/core/Mage/Api/Model/User.php
index ca41612d51d..356bc557c4a 100644
--- app/code/core/Mage/Api/Model/User.php
+++ app/code/core/Mage/Api/Model/User.php
@@ -342,7 +342,7 @@ class Mage_Api_Model_User extends Mage_Core_Model_Abstract
      */
     protected function _getEncodedApiKey($apiKey)
     {
-        return $this->_getHelper('core')->getHash($apiKey, Mage_Admin_Model_User::HASH_SALT_LENGTH);
+        return $this->_getHelper('core')->getHashPassword($apiKey, Mage_Admin_Model_User::HASH_SALT_LENGTH);
     }
 
     /**
@@ -355,4 +355,75 @@ class Mage_Api_Model_User extends Mage_Core_Model_Abstract
     {
         return Mage::helper($helperName);
     }
+
+    /**
+     * Validate user attribute values.
+     *
+     * @return array|bool
+     * @throws Zend_Validate_Exception
+     */
+    public function validate()
+    {
+        $errors = new ArrayObject();
+
+        if (!Zend_Validate::is($this->getUsername(), 'NotEmpty')) {
+            $errors[] = $this->_getHelper('api')->__('User Name is required field.');
+        }
+
+        if (!Zend_Validate::is($this->getFirstname(), 'NotEmpty')) {
+            $errors[] = $this->_getHelper('api')->__('First Name is required field.');
+        }
+
+        if (!Zend_Validate::is($this->getLastname(), 'NotEmpty')) {
+            $errors[] = $this->_getHelper('api')->__('Last Name is required field.');
+        }
+
+        if (!Zend_Validate::is($this->getEmail(), 'EmailAddress')) {
+            $errors[] = $this->_getHelper('api')->__('Please enter a valid email.');
+        }
+
+        if ($this->hasNewApiKey()) {
+            $apiKey = $this->getNewApiKey();
+        } elseif ($this->hasApiKey()) {
+            $apiKey = $this->getApiKey();
+        }
+
+        if (isset($apiKey)) {
+            $minCustomerPasswordLength = $this->_getMinCustomerPasswordLength();
+            if (strlen($apiKey) < $minCustomerPasswordLength) {
+                $errors[] = $this->_getHelper('api')
+                    ->__('Api Key must be at least of %d characters.', $minCustomerPasswordLength);
+            }
+
+            if (!preg_match('/[a-z]/iu', $apiKey) || !preg_match('/[0-9]/u', $apiKey)) {
+                $errors[] = $this->_getHelper('api')
+                    ->__('Api Key must include both numeric and alphabetic characters.');
+            }
+
+            if ($this->hasApiKeyConfirmation() && $apiKey != $this->getApiKeyConfirmation()) {
+                $errors[] = $this->_getHelper('api')->__('Api Key confirmation must be same as Api Key.');
+            }
+        }
+
+        if ($this->userExists()) {
+            $errors[] = $this->_getHelper('api')
+                ->__('A user with the same user name or email already exists.');
+        }
+
+        if (count($errors) === 0) {
+            return true;
+        }
+
+        return (array) $errors;
+    }
+
+    /**
+     * Get min customer password length
+     *
+     * @return int
+     */
+    protected function _getMinCustomerPasswordLength()
+    {
+        return Mage::getSingleton('customer/customer')->getMinPasswordLength();
+    }
 }
diff --git app/code/core/Mage/Api/etc/config.xml app/code/core/Mage/Api/etc/config.xml
index 578736d1e9b..8c66b80fc11 100644
--- app/code/core/Mage/Api/etc/config.xml
+++ app/code/core/Mage/Api/etc/config.xml
@@ -28,7 +28,7 @@
 <config>
     <modules>
         <Mage_Api>
-            <version>1.6.0.1</version>
+            <version>1.6.0.2</version>
         </Mage_Api>
     </modules>
     <global>
diff --git app/code/core/Mage/Api/sql/api_setup/mysql4-upgrade-1.6.0.1-1.6.0.2.php app/code/core/Mage/Api/sql/api_setup/mysql4-upgrade-1.6.0.1-1.6.0.2.php
new file mode 100644
index 00000000000..63b039e0549
--- /dev/null
+++ app/code/core/Mage/Api/sql/api_setup/mysql4-upgrade-1.6.0.1-1.6.0.2.php
@@ -0,0 +1,41 @@
+<?php
+/**
+ * Magento
+ *
+ * NOTICE OF LICENSE
+ *
+ * This source file is subject to the Open Software License (OSL 3.0)
+ * that is bundled with this package in the file LICENSE.txt.
+ * It is also available through the world-wide-web at this URL:
+ * http://opensource.org/licenses/osl-3.0.php
+ * If you did not receive a copy of the license and are unable to
+ * obtain it through the world-wide-web, please send an email
+ * to license@magento.com so we can send you a copy immediately.
+ *
+ * DISCLAIMER
+ *
+ * Do not edit or add to this file if you wish to upgrade Magento to newer
+ * versions in the future. If you wish to customize Magento for your
+ * needs please refer to http://www.magento.com for more information.
+ *
+ * @category    Mage
+ * @package     Mage_Api
+ * @copyright  Copyright (c) 2006-2019 Magento, Inc. (http://www.magento.com)
+ * @license    http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
+ */
+
+/* @var $this Mage_Core_Model_Resource_Setup */
+$this->startSetup();
+
+$this->getConnection()->changeColumn(
+    $this->getTable('api/user'),
+    'api_key',
+    'api_key',
+    array(
+        'type' => Varien_Db_Ddl_Table::TYPE_TEXT,
+        'length' => 255,
+        'comment' => 'Api key'
+    )
+);
+
+$this->endSetup();
diff --git app/code/core/Mage/Catalog/Block/Product/Abstract.php app/code/core/Mage/Catalog/Block/Product/Abstract.php
index 99c8fea9afa..84e42afd519 100644
--- app/code/core/Mage/Catalog/Block/Product/Abstract.php
+++ app/code/core/Mage/Catalog/Block/Product/Abstract.php
@@ -114,21 +114,7 @@ abstract class Mage_Catalog_Block_Product_Abstract extends Mage_Core_Block_Templ
      */
     public function getAddToCartUrl($product, $additional = array())
     {
-        if (!$product->getTypeInstance(true)->hasRequiredOptions($product)) {
-            return $this->helper('checkout/cart')->getAddUrl($product, $additional);
-        }
-        $additional = array_merge(
-            $additional,
-            array(Mage_Core_Model_Url::FORM_KEY => $this->_getSingletonModel('core/session')->getFormKey())
-        );
-        if (!isset($additional['_escape'])) {
-            $additional['_escape'] = true;
-        }
-        if (!isset($additional['_query'])) {
-            $additional['_query'] = array();
-        }
-        $additional['_query']['options'] = 'cart';
-        return $this->getProductUrl($product, $additional);
+        return $this->getAddToCartUrlCustom($product, $additional);
     }
 
     /**
@@ -154,15 +140,7 @@ abstract class Mage_Catalog_Block_Product_Abstract extends Mage_Core_Block_Templ
      */
     public function getSubmitUrl($product, $additional = array())
     {
-        $submitRouteData = $this->getData('submit_route_data');
-        if ($submitRouteData) {
-            $route = $submitRouteData['route'];
-            $params = isset($submitRouteData['params']) ? $submitRouteData['params'] : array();
-            $submitUrl = $this->getUrl($route, array_merge($params, $additional));
-        } else {
-            $submitUrl = $this->getAddToCartUrl($product, $additional);
-        }
-        return $submitUrl;
+        return $this->getSubmitUrlCustom($product, $additional);
     }
 
     /**
@@ -173,7 +151,7 @@ abstract class Mage_Catalog_Block_Product_Abstract extends Mage_Core_Block_Templ
      */
     public function getAddToWishlistUrl($product)
     {
-        return $this->helper('wishlist')->getAddUrl($product);
+        return $this->getAddToWishlistUrlCustom($product);
     }
 
     /**
@@ -184,7 +162,7 @@ abstract class Mage_Catalog_Block_Product_Abstract extends Mage_Core_Block_Templ
      */
     public function getAddToCompareUrl($product)
     {
-        return $this->helper('catalog/product_compare')->getAddUrl($product);
+        return $this->getAddToCompareUrlCustom($product);
     }
 
     /**
@@ -645,6 +623,36 @@ abstract class Mage_Catalog_Block_Product_Abstract extends Mage_Core_Block_Templ
         return (boolean)$statusInfo->getDisplayStatus();
     }
 
+    /**
+     * Return link to Add to Wishlist with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product $product
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getAddToWishlistUrlCustom($product, $addFormKey = true)
+    {
+        if (!$addFormKey) {
+            return $this->helper('wishlist')->getAddUrlWithCustomParams($product, array(), false);
+        }
+        return $this->helper('wishlist')->getAddUrl($product);
+    }
+
+    /**
+     * Retrieve Add Product to Compare Products List URL with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product $product
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getAddToCompareUrlCustom($product, $addFormKey = true)
+    {
+        if (!$addFormKey) {
+            return $this->helper('catalog/product_compare')->getAddUrlCustom($product, false);
+        }
+        return $this->helper('catalog/product_compare')->getAddUrl($product);
+    }
+
     /**
      * If exists price template block, retrieve price blocks from it
      *
@@ -664,4 +672,64 @@ abstract class Mage_Catalog_Block_Product_Abstract extends Mage_Core_Block_Templ
 
         return $this;
     }
+
+    /**
+     * Retrieve url for add product to cart with or without Form Key
+     * Will return product view page URL if product has required options
+     *
+     * @param Mage_Catalog_Model_Product $product
+     * @param array $additional
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function  getAddToCartUrlCustom($product, $additional = array(), $addFormKey = true)
+    {
+        if (!$product->getTypeInstance(true)->hasRequiredOptions($product)) {
+            if (!$addFormKey) {
+                return $this->helper('checkout/cart')->getAddUrlCustom($product, $additional, false);
+            }
+            return $this->helper('checkout/cart')->getAddUrl($product, $additional);
+        }
+        if ($addFormKey) {
+            $additional = array_merge(
+                $additional,
+                array(Mage_Core_Model_Url::FORM_KEY => $this->_getSingletonModel('core/session')->getFormKey())
+            );
+        }
+        if (!isset($additional['_escape'])) {
+            $additional['_escape'] = true;
+        }
+        if (!isset($additional['_query'])) {
+            $additional['_query'] = array();
+        }
+        $additional['_query']['options'] = 'cart';
+        return $this->getProductUrl($product, $additional);
+    }
+
+    /**
+     * Retrieves url for form submitting:
+     * some objects can use setSubmitRouteData() to set route and params for form submitting,
+     * otherwise default url will be used with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product $product
+     * @param array $additional
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getSubmitUrlCustom($product, $additional = array(), $addFormKey = true)
+    {
+        $submitRouteData = $this->getData('submit_route_data');
+        if ($submitRouteData) {
+            $route = $submitRouteData['route'];
+            $params = isset($submitRouteData['params']) ? $submitRouteData['params'] : array();
+            $submitUrl = $this->getUrl($route, array_merge($params, $additional));
+        } else {
+            if ($addFormKey) {
+                $submitUrl = $this->getAddToCartUrl($product, $additional);
+            } else {
+                $submitUrl = $this->getAddToCartUrlCustom($product, $additional, false);
+            }
+        }
+        return $submitUrl;
+    }
 }
diff --git app/code/core/Mage/Catalog/Block/Product/Compare/List.php app/code/core/Mage/Catalog/Block/Product/Compare/List.php
index c447194b797..0514bf49224 100644
--- app/code/core/Mage/Catalog/Block/Product/Compare/List.php
+++ app/code/core/Mage/Catalog/Block/Product/Compare/List.php
@@ -77,14 +77,7 @@ class Mage_Catalog_Block_Product_Compare_List extends Mage_Catalog_Block_Product
      */
     public function getAddToWishlistUrl($product)
     {
-        $continueUrl    = Mage::helper('core')->urlEncode($this->getUrl('customer/account'));
-        $urlParamName   = Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED;
-
-        $params = array(
-            $urlParamName   => $continueUrl
-        );
-
-        return $this->helper('wishlist')->getAddUrlWithParams($product, $params);
+        return $this->getAddToWishlistUrlCustom($product);
     }
 
     /**
@@ -195,4 +188,26 @@ class Mage_Catalog_Block_Product_Compare_List extends Mage_Catalog_Block_Product
         $this->_customerId = $id;
         return $this;
     }
+
+    /**
+     * Retrieve url for adding product to wishlist with params with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product $product
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getAddToWishlistUrlCustom($product, $addFormKey = true)
+    {
+        $continueUrl = Mage::helper('core')->urlEncode($this->getUrl('customer/account'));
+        $params = array(
+            Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED => $continueUrl
+        );
+
+        if (!$addFormKey) {
+            return $this->helper('wishlist')->getAddUrlWithCustomParams($product, $params, false);
+        }
+
+        return $this->helper('wishlist')->getAddUrlWithParams($product, $params);
+    }
+
 }
diff --git app/code/core/Mage/Catalog/Block/Product/Price.php app/code/core/Mage/Catalog/Block/Product/Price.php
old mode 100755
new mode 100644
index cde7ff38113..289e0797521
--- app/code/core/Mage/Catalog/Block/Product/Price.php
+++ app/code/core/Mage/Catalog/Block/Product/Price.php
@@ -179,7 +179,7 @@ class Mage_Catalog_Block_Product_Price extends Mage_Catalog_Block_Product_Abstra
      */
     public function getAddToCartUrl($product, $additional = array())
     {
-        return $this->helper('checkout/cart')->getAddUrl($product, $additional);
+        return $this->getAddToCartUrlCustom($product, $additional);
     }
 
     /**
@@ -229,4 +229,20 @@ class Mage_Catalog_Block_Product_Price extends Mage_Catalog_Block_Product_Abstra
     {
         return $this->getProduct()->getResource()->getAttribute($attribute);
     }
+
+    /**
+     * Retrieve url for direct adding product to cart with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product $product
+     * @param array $additional
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getAddToCartUrlCustom($product, $additional = array(), $addFormKey = true)
+    {
+        if (!$addFormKey) {
+            return $this->helper('checkout/cart')->getAddUrlCustom($product, $additional, false);
+        }
+        return $this->helper('checkout/cart')->getAddUrl($product, $additional);
+    }
 }
diff --git app/code/core/Mage/Catalog/Block/Product/View.php app/code/core/Mage/Catalog/Block/Product/View.php
old mode 100755
new mode 100644
index b582372820d..c4b93ecc345
--- app/code/core/Mage/Catalog/Block/Product/View.php
+++ app/code/core/Mage/Catalog/Block/Product/View.php
@@ -113,19 +113,7 @@ class Mage_Catalog_Block_Product_View extends Mage_Catalog_Block_Product_Abstrac
      */
     public function getAddToCartUrl($product, $additional = array())
     {
-        if ($this->hasCustomAddToCartUrl()) {
-            return $this->getCustomAddToCartUrl();
-        }
-
-        if ($this->getRequest()->getParam('wishlist_next')) {
-            $additional['wishlist_next'] = 1;
-        }
-
-        $addUrlKey = Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED;
-        $addUrlValue = Mage::getUrl('*/*/*', array('_use_rewrite' => true, '_current' => true));
-        $additional[$addUrlKey] = Mage::helper('core')->urlEncode($addUrlValue);
-
-        return $this->helper('checkout/cart')->getAddUrl($product, $additional);
+        return $this->getAddToCartUrlCustom($product, $additional);
     }
 
     /**
@@ -276,4 +264,34 @@ class Mage_Catalog_Block_Product_View extends Mage_Catalog_Block_Product_Abstrac
     {
         return array_merge(parent::getCacheTags(), $this->getProduct()->getCacheIdTags());
     }
+
+    /**
+     * Retrieve url for direct adding product to cart with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product $product
+     * @param array $additional
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getAddToCartUrlCustom($product, $additional = array(), $addFormKey = true)
+    {
+        if (!$addFormKey && $this->hasCustomAddToCartPostUrl()) {
+            return $this->getCustomAddToCartPostUrl();
+        } elseif ($this->hasCustomAddToCartUrl()) {
+            return $this->getCustomAddToCartUrl();
+        }
+
+        if ($this->getRequest()->getParam('wishlist_next')) {
+            $additional['wishlist_next'] = 1;
+        }
+
+        $addUrlValue = Mage::getUrl('*/*/*', array('_use_rewrite' => true, '_current' => true));
+        $additional[Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED] =
+            Mage::helper('core')->urlEncode($addUrlValue);
+
+        if (!$addFormKey) {
+            return $this->helper('checkout/cart')->getAddUrlCustom($product, $additional, false);
+        }
+        return $this->helper('checkout/cart')->getAddUrl($product, $additional);
+    }
 }
diff --git app/code/core/Mage/Catalog/Helper/Product/Compare.php app/code/core/Mage/Catalog/Helper/Product/Compare.php
index 95549d3af15..b5059ba0838 100644
--- app/code/core/Mage/Catalog/Helper/Product/Compare.php
+++ app/code/core/Mage/Catalog/Helper/Product/Compare.php
@@ -100,11 +100,7 @@ class Mage_Catalog_Helper_Product_Compare extends Mage_Core_Helper_Url
      */
     protected function _getUrlParams($product)
     {
-        return array(
-            'product' => $product->getId(),
-            Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED => $this->getEncodedUrl(),
-            Mage_Core_Model_Url::FORM_KEY => $this->_getSingletonModel('core/session')->getFormKey()
-        );
+        return $this->_getUrlCustomParams($product);
     }
 
     /**
@@ -115,7 +111,7 @@ class Mage_Catalog_Helper_Product_Compare extends Mage_Core_Helper_Url
      */
     public function getAddUrl($product)
     {
-        return $this->_getUrl('catalog/product_compare/add', $this->_getUrlParams($product));
+        return $this->getAddUrlCustom($product);
     }
 
     /**
@@ -126,15 +122,7 @@ class Mage_Catalog_Helper_Product_Compare extends Mage_Core_Helper_Url
      */
     public function getAddToWishlistUrl($product)
     {
-        $beforeCompareUrl = Mage::getSingleton('catalog/session')->getBeforeCompareUrl();
-
-        $params = array(
-            'product' => $product->getId(),
-            Mage_Core_Model_Url::FORM_KEY => $this->_getSingletonModel('core/session')->getFormKey(),
-            Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED => $this->getEncodedUrl($beforeCompareUrl)
-        );
-
-        return $this->_getUrl('wishlist/index/add', $params);
+        return $this->getAddToWishlistUrlCustom($product);
     }
 
     /**
@@ -145,14 +133,7 @@ class Mage_Catalog_Helper_Product_Compare extends Mage_Core_Helper_Url
      */
     public function getAddToCartUrl($product)
     {
-        $beforeCompareUrl = $this->_getSingletonModel('catalog/session')->getBeforeCompareUrl();
-        $params = array(
-            'product' => $product->getId(),
-            Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED => $this->getEncodedUrl($beforeCompareUrl),
-            Mage_Core_Model_Url::FORM_KEY => $this->_getSingletonModel('core/session')->getFormKey()
-        );
-
-        return $this->_getUrl('checkout/cart/add', $params);
+        return $this->getAddToCartUrlCustom($product);
     }
 
     /**
@@ -314,4 +295,71 @@ class Mage_Catalog_Helper_Product_Compare extends Mage_Core_Helper_Url
         $this->_customerId = $id;
         return $this;
     }
+
+    /**
+     * Retrieve url for adding product to conpare list with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product $product
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getAddUrlCustom($product, $addFormKey = true)
+    {
+        return $this->_getUrl('catalog/product_compare/add', $this->_getUrlCustomParams($product, $addFormKey));
+    }
+
+    /**
+     * Retrive add to wishlist url with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product $product
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getAddToWishlistUrlCustom($product, $addFormKey = true)
+    {
+        $beforeCompareUrl = Mage::getSingleton('catalog/session')->getBeforeCompareUrl();
+        $params = $this->_getUrlCustomParams($product, $addFormKey, $beforeCompareUrl);
+
+        return $this->_getUrl('wishlist/index/add', $params);
+    }
+
+    /**
+     * Retrive add to cart url with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product $product
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getAddToCartUrlCustom($product, $addFormKey = true)
+    {
+        $beforeCompareUrl = Mage::getSingleton('catalog/session')->getBeforeCompareUrl();
+        $params = array(
+            'product' => $product->getId(),
+            Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED => $this->getEncodedUrl($beforeCompareUrl),
+        );
+        if ($addFormKey) {
+            $params[Mage_Core_Model_Url::FORM_KEY] = Mage::getSingleton('core/session')->getFormKey();
+        }
+
+        return $this->_getUrl('checkout/cart/add', $params);
+    }
+
+    /**
+     * Get parameters used for build add product to compare list urls with or without Form Key
+     *
+     * @param   Mage_Catalog_Model_Product $product
+     * @param bool $addFormKey
+     * @return  array
+     */
+    protected function _getUrlCustomParams($product, $addFormKey = true, $url = null)
+    {
+        $params = array(
+            'product' => $product->getId(),
+            Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED => $this->getEncodedUrl($url),
+        );
+        if ($addFormKey) {
+            $params[Mage_Core_Model_Url::FORM_KEY] = Mage::getSingleton('core/session')->getFormKey();
+        }
+        return $params;
+    }
 }
diff --git app/code/core/Mage/Catalog/Model/Design.php app/code/core/Mage/Catalog/Model/Design.php
index a9325e4c7d3..5fc521afb88 100644
--- app/code/core/Mage/Catalog/Model/Design.php
+++ app/code/core/Mage/Catalog/Model/Design.php
@@ -375,9 +375,19 @@ class Mage_Catalog_Model_Design extends Mage_Core_Model_Abstract
         $date = $object->getCustomDesignDate();
         if (array_key_exists('from', $date) && array_key_exists('to', $date)
             && Mage::app()->getLocale()->isStoreDateInInterval(null, $date['from'], $date['to'])) {
-                $settings->setCustomDesign($object->getCustomDesign())
-                    ->setPageLayout($object->getPageLayout())
-                    ->setLayoutUpdates((array)$object->getCustomLayoutUpdate());
+            $customLayout = $object->getCustomLayoutUpdate();
+            if ($customLayout) {
+                try {
+                    if (!Mage::getModel('core/layout_validator')->isValid($customLayout)) {
+                        $customLayout = '';
+                    }
+                } catch (Exception $e) {
+                    $customLayout = '';
+                }
+            }
+            $settings->setCustomDesign($object->getCustomDesign())
+                ->setPageLayout($object->getPageLayout())
+                ->setLayoutUpdates((array)$customLayout);
         }
         return $settings;
     }
diff --git app/code/core/Mage/Catalog/etc/config.xml app/code/core/Mage/Catalog/etc/config.xml
index dc657294f5d..2b22a8d916e 100644
--- app/code/core/Mage/Catalog/etc/config.xml
+++ app/code/core/Mage/Catalog/etc/config.xml
@@ -28,7 +28,7 @@
 <config>
     <modules>
         <Mage_Catalog>
-            <version>1.6.0.0.18</version>
+            <version>1.6.0.0.18.1.2</version>
         </Mage_Catalog>
     </modules>
     <admin>
diff --git app/code/core/Mage/Catalog/sql/catalog_setup/upgrade-1.6.0.0.18.1.1-1.6.0.0.18.1.2.php app/code/core/Mage/Catalog/sql/catalog_setup/upgrade-1.6.0.0.18.1.1-1.6.0.0.18.1.2.php
new file mode 100644
index 00000000000..d2863c47aa5
--- /dev/null
+++ app/code/core/Mage/Catalog/sql/catalog_setup/upgrade-1.6.0.0.18.1.1-1.6.0.0.18.1.2.php
@@ -0,0 +1,44 @@
+<?php
+/**
+ * Magento
+ *
+ * NOTICE OF LICENSE
+ *
+ * This source file is subject to the Open Software License (OSL 3.0)
+ * that is bundled with this package in the file LICENSE.txt.
+ * It is also available through the world-wide-web at this URL:
+ * http://opensource.org/licenses/osl-3.0.php
+ * If you did not receive a copy of the license and are unable to
+ * obtain it through the world-wide-web, please send an email
+ * to license@magento.com so we can send you a copy immediately.
+ *
+ * DISCLAIMER
+ *
+ * Do not edit or add to this file if you wish to upgrade Magento to newer
+ * versions in the future. If you wish to customize Magento for your
+ * needs please refer to http://www.magento.com for more information.
+ *
+ * @category    Mage
+ * @package     Mage_Catalog
+ * @copyright  Copyright (c) 2006-2019 Magento, Inc. (http://www.magento.com)
+ * @license    http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
+ */
+
+/* @var $installer Mage_Catalog_Model_Resource_Setup */
+$installer = $this;
+$attributeId = 'custom_layout_update';
+
+$entitiesToUpgrade = [
+    $installer->getEntityTypeId('catalog_product'),
+    $installer->getEntityTypeId('catalog_category'),
+];
+foreach ($entitiesToUpgrade as $entityTypeId) {
+    if ($this->getAttributeId($entityTypeId, $attributeId)) {
+        $installer->updateAttribute(
+            $entityTypeId,
+            $attributeId,
+            'backend_model',
+            'catalog/attribute_backend_customlayoutupdate'
+        );
+    }
+}
diff --git app/code/core/Mage/Checkout/Block/Cart/Item/Renderer.php app/code/core/Mage/Checkout/Block/Cart/Item/Renderer.php
old mode 100755
new mode 100644
index 3d939fbb9c7..cadb074f268
--- app/code/core/Mage/Checkout/Block/Cart/Item/Renderer.php
+++ app/code/core/Mage/Checkout/Block/Cart/Item/Renderer.php
@@ -215,19 +215,31 @@ class Mage_Checkout_Block_Cart_Item_Renderer extends Mage_Core_Block_Template
      * @return string
      */
     public function getDeleteUrl()
+    {
+        return $this->getDeleteUrlCustom();
+    }
+
+    /**
+     * Get item delete url with or without Form Key
+     *
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getDeleteUrlCustom($addFormKey = true)
     {
         if ($this->hasDeleteUrl()) {
             return $this->getData('delete_url');
         }
 
-        return $this->getUrl(
-            'checkout/cart/delete',
-            array(
-                'id'=>$this->getItem()->getId(),
-                'form_key' => Mage::getSingleton('core/session')->getFormKey(),
-                Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED => $this->helper('core/url')->getEncodedUrl()
-            )
+        $params = array(
+            'id' => $this->getItem()->getId(),
+            Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED => $this->helper('core/url')->getEncodedUrl(),
         );
+        if ($addFormKey) {
+            $params[Mage_Core_Model_Url::FORM_KEY] = Mage::getSingleton('core/session')->getFormKey();
+        }
+
+        return $this->getUrl('checkout/cart/delete', $params);
     }
 
     /**
diff --git app/code/core/Mage/Checkout/Helper/Cart.php app/code/core/Mage/Checkout/Helper/Cart.php
index 0a53e8dc6c5..d62c0e54222 100644
--- app/code/core/Mage/Checkout/Helper/Cart.php
+++ app/code/core/Mage/Checkout/Helper/Cart.php
@@ -60,28 +60,7 @@ class Mage_Checkout_Helper_Cart extends Mage_Core_Helper_Url
      */
     public function getAddUrl($product, $additional = array())
     {
-        $routeParams = array(
-            Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED => $this->_getHelperInstance('core')
-                ->urlEncode($this->getCurrentUrl()),
-            'product' => $product->getEntityId(),
-            Mage_Core_Model_Url::FORM_KEY => $this->_getSingletonModel('core/session')->getFormKey()
-        );
-
-        if (!empty($additional)) {
-            $routeParams = array_merge($routeParams, $additional);
-        }
-
-        if ($product->hasUrlDataObject()) {
-            $routeParams['_store'] = $product->getUrlDataObject()->getStoreId();
-            $routeParams['_store_to_url'] = true;
-        }
-
-        if ($this->_getRequest()->getRouteName() == 'checkout'
-            && $this->_getRequest()->getControllerName() == 'cart') {
-            $routeParams['in_cart'] = 1;
-        }
-
-        return $this->_getUrl('checkout/cart/add', $routeParams);
+        return $this->getAddUrlCustom($product, $additional);
     }
 
     /**
@@ -180,4 +159,39 @@ class Mage_Checkout_Helper_Cart extends Mage_Core_Helper_Url
     {
         return Mage::getStoreConfigFlag(self::XML_PATH_REDIRECT_TO_CART, $store);
     }
+
+    /**
+     * Retrieve url for add product to cart with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product $product
+     * @param array $additional
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getAddUrlCustom($product, $additional = array(), $addFormKey = true)
+    {
+        $routeParams = array(
+            Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED => $this->_getHelperInstance('core')
+                ->urlEncode($this->getCurrentUrl()),
+            'product' => $product->getEntityId(),
+        );
+        if ($addFormKey) {
+            $routeParams[Mage_Core_Model_Url::FORM_KEY] = $this->_getSingletonModel('core/session')->getFormKey();
+        }
+        if (!empty($additional)) {
+            $routeParams = array_merge($routeParams, $additional);
+        }
+        if ($product->hasUrlDataObject()) {
+            $routeParams['_store'] = $product->getUrlDataObject()->getStoreId();
+            $routeParams['_store_to_url'] = true;
+        }
+        if (
+            $this->_getRequest()->getRouteName() == 'checkout'
+            && $this->_getRequest()->getControllerName() == 'cart'
+        ) {
+            $routeParams['in_cart'] = 1;
+        }
+
+        return $this->_getUrl('checkout/cart/add', $routeParams);
+    }
 }
diff --git app/code/core/Mage/Checkout/Model/Session.php app/code/core/Mage/Checkout/Model/Session.php
index f1ae4a91329..bdac8230628 100644
--- app/code/core/Mage/Checkout/Model/Session.php
+++ app/code/core/Mage/Checkout/Model/Session.php
@@ -120,21 +120,13 @@ class Mage_Checkout_Model_Session extends Mage_Core_Model_Session_Abstract
         if ($this->_quote === null) {
             /** @var $quote Mage_Sales_Model_Quote */
             $quote = Mage::getModel('sales/quote')->setStoreId(Mage::app()->getStore()->getId());
-            $customerSession = Mage::getSingleton('customer/session');
-
             if ($this->getQuoteId()) {
                 if ($this->_loadInactive) {
                     $quote->load($this->getQuoteId());
                 } else {
                     $quote->loadActive($this->getQuoteId());
                 }
-                if (
-                    $quote->getId()
-                    && (
-                        ($customerSession->isLoggedIn() && $customerSession->getId() == $quote->getCustomerId())
-                        || (!$customerSession->isLoggedIn() && !$quote->getCustomerId())
-                    )
-                ) {
+                if ($quote->getId()) {
                     /**
                      * If current currency code of quote is not equal current currency code of store,
                      * need recalculate totals of quote. It is possible if customer use currency switcher or
@@ -151,16 +143,16 @@ class Mage_Checkout_Model_Session extends Mage_Core_Model_Session_Abstract
                         $quote->load($this->getQuoteId());
                     }
                 } else {
-                    $quote->unsetData();
                     $this->setQuoteId(null);
                 }
             }
 
+            $customerSession = Mage::getSingleton('customer/session');
+
             if (!$this->getQuoteId()) {
                 if ($customerSession->isLoggedIn() || $this->_customer) {
                     $customer = ($this->_customer) ? $this->_customer : $customerSession->getCustomer();
                     $quote->loadByCustomer($customer);
-                    $quote->setCustomer($customer);
                     $this->setQuoteId($quote->getId());
                 } else {
                     $quote->setIsCheckoutCart(true);
diff --git app/code/core/Mage/Cms/Block/Widget/Block.php app/code/core/Mage/Cms/Block/Widget/Block.php
index b2603f1eafd..95c6022d7fd 100644
--- app/code/core/Mage/Cms/Block/Widget/Block.php
+++ app/code/core/Mage/Cms/Block/Widget/Block.php
@@ -66,11 +66,27 @@ class Mage_Cms_Block_Widget_Block extends Mage_Core_Block_Template implements Ma
                 /* @var $helper Mage_Cms_Helper_Data */
                 $helper = Mage::helper('cms');
                 $processor = $helper->getBlockTemplateProcessor();
-                $this->setText($processor->filter($block->getContent()));
+                if ($this->isRequestFromAdminArea()) {
+                    $this->setText($processor->filter(
+                        Mage::getSingleton('core/input_filter_maliciousCode')->filter($block->getContent())
+                    ));
+                } else {
+                    $this->setText($processor->filter($block->getContent()));
+                }
             }
         }
 
         unset(self::$_widgetUsageMap[$blockHash]);
         return $this;
     }
+
+    /**
+     * Check is request goes from admin area
+     *
+     * @return bool
+     */
+    public function isRequestFromAdminArea()
+    {
+        return $this->getRequest()->getRouteName() === Mage_Core_Model_App_Area::AREA_ADMINHTML;
+    }
 }
diff --git app/code/core/Mage/Core/Block/Abstract.php app/code/core/Mage/Core/Block/Abstract.php
index d561bf308b4..083e860c875 100644
--- app/code/core/Mage/Core/Block/Abstract.php
+++ app/code/core/Mage/Core/Block/Abstract.php
@@ -1393,6 +1393,16 @@ abstract class Mage_Core_Block_Abstract extends Varien_Object
         return $this->getData('cache_lifetime');
     }
 
+    /**
+     * Retrieve Session Form Key
+     *
+     * @return string
+     */
+    public function getFormKey()
+    {
+        return Mage::getSingleton('core/session')->getFormKey();
+    }
+
     /**
      * Load block html from cache storage
      *
@@ -1497,4 +1507,14 @@ abstract class Mage_Core_Block_Abstract extends Varien_Object
         }
         return $tags;
     }
+
+    /**
+     * Checks is request Url is secure
+     *
+     * @return bool
+     */
+    protected function _isSecure()
+    {
+        return $this->_getApp()->getFrontController()->getRequest()->isSecure();
+    }
 }
diff --git app/code/core/Mage/Core/Controller/Request/Http.php app/code/core/Mage/Core/Controller/Request/Http.php
index 83f6802abc3..a0929d09577 100644
--- app/code/core/Mage/Core/Controller/Request/Http.php
+++ app/code/core/Mage/Core/Controller/Request/Http.php
@@ -262,9 +262,9 @@ class Mage_Core_Controller_Request_Http extends Zend_Controller_Request_Http
         return $path;
     }
 
-    public function getBaseUrl()
+    public function getBaseUrl($raw = false)
     {
-        $url = parent::getBaseUrl();
+        $url = parent::getBaseUrl($raw);
         $url = str_replace('\\', '/', $url);
         return $url;
     }
diff --git app/code/core/Mage/Core/Helper/Data.php app/code/core/Mage/Core/Helper/Data.php
index e5d97eaafde..9ebb49dda47 100644
--- app/code/core/Mage/Core/Helper/Data.php
+++ app/code/core/Mage/Core/Helper/Data.php
@@ -271,11 +271,41 @@ class Mage_Core_Helper_Data extends Mage_Core_Helper_Abstract
         return $this->getEncryptor()->getHash($password, $salt);
     }
 
+    /**
+     *  Generate password hash for user
+     *
+     * @param string $password
+     * @param mixed $salt
+     * @return string
+     */
+    public function getHashPassword($password, $salt = false)
+    {
+        $encryptionModel = $this->getEncryptor();
+        $latestVersionHash = $this->getVersionHash($encryptionModel);
+        if ($latestVersionHash == $encryptionModel::HASH_VERSION_SHA512) {
+            return $this->getEncryptor()->getHashPassword($password, $salt);
+        }
+        return $this->getEncryptor()->getHashPassword($password, Mage_Admin_Model_User::HASH_SALT_EMPTY);
+    }
+
     public function validateHash($password, $hash)
     {
         return $this->getEncryptor()->validateHash($password, $hash);
     }
 
+    /**
+     * Get encryption method depending on the presence of the function - password_hash.
+     *
+     * @param Mage_Core_Model_Encryption $encryptionModel
+     * @return int
+     */
+    public function getVersionHash(Mage_Core_Model_Encryption $encryptionModel)
+    {
+        return function_exists('password_hash')
+            ? $encryptionModel::HASH_VERSION_LATEST
+            : $encryptionModel::HASH_VERSION_SHA512;
+    }
+
     /**
      * Retrieve store identifier
      *
diff --git app/code/core/Mage/Core/Helper/String.php app/code/core/Mage/Core/Helper/String.php
index a0d64ab064c..8550fa221fc 100644
--- app/code/core/Mage/Core/Helper/String.php
+++ app/code/core/Mage/Core/Helper/String.php
@@ -323,4 +323,35 @@ class Mage_Core_Helper_String extends Mage_Core_Helper_Abstract
         return $sort;
     }
 
+    /**
+     * Detect serialization of data Array or Object
+     *
+     * @param mixed $data
+     * @return bool
+     */
+    public function isSerializedArrayOrObject($data)
+    {
+        $pattern =
+            '/^a:\d+:\{(i:\d+;|s:\d+:\".+\";|N;|O:\d+:\"\w+\":\d+:\{\w:\d+:)+|^O:\d+:\"\w+\":\d+:\{(s:\d+:\"|i:\d+;)/';
+        return is_string($data) && preg_match($pattern, $data);
+    }
+
+    /**
+     * Validate is Serialized Data Object in string
+     *
+     * @param string $str
+     * @return bool
+     */
+    public function validateSerializedObject($str)
+    {
+        if ($this->isSerializedArrayOrObject($str)) {
+            try {
+                $this->unserialize($str);
+            } catch (Exception $e) {
+                return false;
+            }
+        }
+
+        return true;
+    }
 }
diff --git app/code/core/Mage/Core/Model/App.php app/code/core/Mage/Core/Model/App.php
index 8e69a3340a1..0e777456f64 100644
--- app/code/core/Mage/Core/Model/App.php
+++ app/code/core/Mage/Core/Model/App.php
@@ -72,6 +72,22 @@ class Mage_Core_Model_App
      */
     const ADMIN_STORE_ID = 0;
 
+    /**
+     * The absolute minimum of password length for all types of passwords
+     *
+     * With changing this value also need to change:
+     * 1. in `js/prototype/validation.js` declarations `var minLength = 7;` in two places;
+     * 2. in `app/code/core/Mage/Customer/etc/system.xml`
+     *    comments for fields `min_password_length` and `min_admin_password_length`
+     *    `<comment>Please enter a number 7 or greater in this field.</comment>`;
+     * 3. in `app/code/core/Mage/Customer/etc/config.xml` value `<min_password_length>7</min_password_length>`
+     *    and, maybe, value `<min_admin_password_length>14</min_admin_password_length>`
+     *    (if the absolute minimum of password length is higher then this value);
+     * 4. maybe, the value of deprecated `const MIN_PASSWORD_LENGTH` in `app/code/core/Mage/Admin/Model/User.php`,
+     *    (if the absolute minimum of password length is higher then this value).
+     */
+    const ABSOLUTE_MIN_PASSWORD_LENGTH = 7;
+
     /**
      * Application loaded areas array
      *
diff --git app/code/core/Mage/Core/Model/Encryption.php app/code/core/Mage/Core/Model/Encryption.php
index bb5f959eb2b..e5fa678226c 100644
--- app/code/core/Mage/Core/Model/Encryption.php
+++ app/code/core/Mage/Core/Model/Encryption.php
@@ -33,6 +33,14 @@
  */
 class Mage_Core_Model_Encryption
 {
+    const HASH_VERSION_MD5    = 0;
+    const HASH_VERSION_SHA512 = 2;
+
+    /**
+     * Encryption method bcrypt
+     */
+    const HASH_VERSION_LATEST = 3;
+
     /**
      * @var Varien_Crypt_Mcrypt
      */
@@ -74,14 +82,37 @@ class Mage_Core_Model_Encryption
         return $salt === false ? $this->hash($password) : $this->hash($salt . $password) . ':' . $salt;
     }
 
+    /**
+     * Generate hash for customer password
+     *
+     * @param string $password
+     * @param mixed $salt
+     * @return string
+     */
+    public function getHashPassword($password, $salt = null)
+    {
+        if (is_integer($salt)) {
+            $salt = $this->_helper->getRandomString($salt);
+        }
+        return (bool) $salt
+            ? $this->hash($salt . $password, $this->_helper->getVersionHash($this)) . ':' . $salt
+            : $this->hash($password, $this->_helper->getVersionHash($this));
+    }
+
     /**
      * Hash a string
      *
      * @param string $data
-     * @return string
+     * @param int $version
+     * @return bool|string
      */
-    public function hash($data)
+    public function hash($data, $version = self::HASH_VERSION_MD5)
     {
+        if (self::HASH_VERSION_LATEST === $version && $version === $this->_helper->getVersionHash($this)) {
+            return password_hash($data, PASSWORD_DEFAULT);
+        } elseif (self::HASH_VERSION_SHA512 == $version) {
+            return hash('sha512', $data);
+        }
         return md5($data);
     }
 
@@ -95,14 +126,31 @@ class Mage_Core_Model_Encryption
      */
     public function validateHash($password, $hash)
     {
-        $hashArr = explode(':', $hash);
-        switch (count($hashArr)) {
-            case 1:
-                return hash_equals($this->hash($password), $hash);
-            case 2:
-                return hash_equals($this->hash($hashArr[1] . $password),  $hashArr[0]);
+        return $this->validateHashByVersion($password, $hash, self::HASH_VERSION_LATEST)
+            || $this->validateHashByVersion($password, $hash, self::HASH_VERSION_SHA512)
+            || $this->validateHashByVersion($password, $hash, self::HASH_VERSION_MD5);
+    }
+
+    /**
+     * Validate hash by specified version
+     *
+     * @param string $password
+     * @param string $hash
+     * @param int $version
+     * @return bool
+     */
+    public function validateHashByVersion($password, $hash, $version = self::HASH_VERSION_MD5)
+    {
+        if ($version == self::HASH_VERSION_LATEST && $version == $this->_helper->getVersionHash($this)) {
+            return password_verify($password, $hash);
+        }
+        // look for salt
+        $hashArr = explode(':', $hash, 2);
+        if (1 === count($hashArr)) {
+            return hash_equals($this->hash($password, $version), $hash);
         }
-        Mage::throwException('Invalid hash.');
+        list($hash, $salt) = $hashArr;
+        return hash_equals($this->hash($salt . $password, $version), $hash);
     }
 
     /**
diff --git app/code/core/Mage/Core/Model/File/Uploader.php app/code/core/Mage/Core/Model/File/Uploader.php
index f91785194b3..2717b9c30d7 100644
--- app/code/core/Mage/Core/Model/File/Uploader.php
+++ app/code/core/Mage/Core/Model/File/Uploader.php
@@ -41,6 +41,13 @@ class Mage_Core_Model_File_Uploader extends Varien_File_Uploader
      */
     protected $_skipDbProcessing = false;
 
+    /**
+     * Max file name length
+     *
+     * @var int
+     */
+    protected $_fileNameMaxLength = 200;
+
     /**
      * Save file to storage
      *
@@ -99,4 +106,25 @@ class Mage_Core_Model_File_Uploader extends Varien_File_Uploader
 
         return parent::checkAllowedExtension($extension);
     }
+
+    /**
+     * Used to save uploaded file into destination folder with
+     * original or new file name (if specified).
+     * Added file name length validation.
+     *
+     * @param string $destinationFolder
+     * @param string|null $newFileName
+     * @return bool|void
+     * @throws Exception
+     */
+    public function save($destinationFolder, $newFileName = null)
+    {
+        $fileName = isset($newFileName) ? $newFileName : $this->_file['name'];
+        if (strlen($fileName) > $this->_fileNameMaxLength) {
+            throw new Exception(
+                Mage::helper('core')->__("File name is too long. Maximum length is %s.", $this->_fileNameMaxLength)
+            );
+        }
+        return parent::save($destinationFolder, $newFileName);
+    }
 }
diff --git app/code/core/Mage/Core/Model/Input/Filter/MaliciousCode.php app/code/core/Mage/Core/Model/Input/Filter/MaliciousCode.php
index 615c08fc995..bbdf6d1e424 100644
--- app/code/core/Mage/Core/Model/Input/Filter/MaliciousCode.php
+++ app/code/core/Mage/Core/Model/Input/Filter/MaliciousCode.php
@@ -20,8 +20,8 @@
  *
  * @category    Mage
  * @package     Mage_Core
- * @copyright   Copyright (c) 2013 Magento Inc. (http://www.magentocommerce.com)
- * @license     http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
+ * @copyright  Copyright (c) 2006-2019 Magento, Inc. (http://www.magento.com)
+ * @license    http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
  */
 
 /**
@@ -50,11 +50,13 @@ class Mage_Core_Model_Input_Filter_MaliciousCode implements Zend_Filter_Interfac
         //js in the style attribute
         '/style=[^<]*((expression\s*?\([^<]*?\))|(behavior\s*:))[^<]*(?=\>)/Uis',
         //js attributes
-        '/(ondblclick|onclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|onload|onunload|onerror)\s*=[^>]*(?=\>)/Uis',
+        '/(ondblclick|onclick|onkeydown|onkeypress|onkeyup|onmousedown|onmousemove|onmouseout|onmouseover|onmouseup|onload|onunload|onerror|onanimationstart)\s*=[^>]*(?=\>)/Uis',
         //tags
         '/<\/?(script|meta|link|frame|iframe).*>/Uis',
         //base64 usage
         '/src\s*=[^<]*base64[^<]*(?=\>)/Uis',
+        //data attribute
+        '/(data(\\\\x3a|:|%3A)(.+?(?=")|.+?(?=\')))/is',
     );
 
     /**
@@ -99,4 +101,64 @@ class Mage_Core_Model_Input_Filter_MaliciousCode implements Zend_Filter_Interfac
         $this->_expressions = $expressions;
         return $this;
     }
+
+    /**
+     * The filter adds safe attributes to the link
+     *
+     * @param string $html
+     * @param bool $removeWrapper flag for remove wrapper tags: Doctype, html, body
+     * @return string
+     * @throws Mage_Core_Exception
+     */
+    public function linkFilter($html, $removeWrapper = true)
+    {
+        if (stristr($html, '<a ') === false) {
+            return $html;
+        }
+
+        $libXmlErrorsState = libxml_use_internal_errors(true);
+        $dom = $this->_initDOMDocument();
+        if (!$dom->loadHTML($html)) {
+            Mage::throwException(Mage::helper('core')->__('HTML filtration has failed.'));
+        }
+
+        $relAttributeDefaultItems = array('noopener', 'noreferrer');
+        /** @var DOMElement $linkItem */
+        foreach ($dom->getElementsByTagName('a') as $linkItem) {
+            $relAttributeItems = array();
+            $relAttributeCurrentValue = $linkItem->getAttribute('rel');
+            if (!empty($relAttributeCurrentValue)) {
+                $relAttributeItems = explode(' ', $relAttributeCurrentValue);
+            }
+            $relAttributeItems = array_unique(array_merge($relAttributeItems, $relAttributeDefaultItems));
+            $linkItem->setAttribute('rel', implode(' ', $relAttributeItems));
+            $linkItem->setAttribute('target', '_blank');
+        }
+
+        if (!$html = $dom->saveHTML()) {
+            Mage::throwException(Mage::helper('core')->__('HTML filtration has failed.'));
+        }
+
+        if ($removeWrapper) {
+            $html = preg_replace('/<(?:!DOCTYPE|\/?(?:html|body))[^>]*>\s*/i', '', $html);
+        }
+
+        libxml_use_internal_errors($libXmlErrorsState);
+
+        return $html;
+    }
+
+    /**
+     * Initialize built-in DOM parser instance
+     *
+     * @return DOMDocument
+     */
+    protected function _initDOMDocument()
+    {
+        $dom = new DOMDocument();
+        $dom->strictErrorChecking = false;
+        $dom->recover = false;
+
+        return $dom;
+    }
 }
diff --git app/code/core/Mage/Core/Model/Layout/Validator.php app/code/core/Mage/Core/Model/Layout/Validator.php
new file mode 100644
index 00000000000..94497b9f246
--- /dev/null
+++ app/code/core/Mage/Core/Model/Layout/Validator.php
@@ -0,0 +1,258 @@
+<?php
+/**
+ * Magento
+ *
+ * NOTICE OF LICENSE
+ *
+ * This source file is subject to the Open Software License (OSL 3.0)
+ * that is bundled with this package in the file LICENSE.txt.
+ * It is also available through the world-wide-web at this URL:
+ * http://opensource.org/licenses/osl-3.0.php
+ * If you did not receive a copy of the license and are unable to
+ * obtain it through the world-wide-web, please send an email
+ * to license@magento.com so we can send you a copy immediately.
+ *
+ * DISCLAIMER
+ *
+ * Do not edit or add to this file if you wish to upgrade Magento to newer
+ * versions in the future. If you wish to customize Magento for your
+ * needs please refer to http://www.magento.com for more information.
+ *
+ * @category    Mage
+ * @package     Mage_Core
+ * @copyright  Copyright (c) 2006-2019 Magento, Inc. (http://www.magento.com)
+ * @license    http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
+ */
+
+/**
+ * Validator for custom layout update
+ *
+ * Validator checked XML validation and protected expressions
+ *
+ * @category   Mage
+ * @package    Mage_Core
+ * @author     Magento Core Team <core@magentocommerce.com>
+ */
+class Mage_Core_Model_Layout_Validator extends Zend_Validate_Abstract
+{
+    const XML_PATH_LAYOUT_DISALLOWED_BLOCKS       = 'validators/custom_layout/disallowed_block';
+    const XML_INVALID                             = 'invalidXml';
+    const INVALID_TEMPLATE_PATH                   = 'invalidTemplatePath';
+    const INVALID_BLOCK_NAME                      = 'invalidBlockName';
+    const PROTECTED_ATTR_HELPER_IN_TAG_ACTION_VAR = 'protectedAttrHelperInActionVar';
+    const INVALID_XML_OBJECT_EXCEPTION            = 'invalidXmlObject';
+
+    /**
+     * The Varien SimpleXml object
+     *
+     * @var Varien_Simplexml_Element
+     */
+    protected $_value;
+
+    /**
+     * XPath expression for checking layout update
+     *
+     * @var array
+     */
+    protected $_disallowedXPathExpressions = array(
+        '*//template',
+        '*//@template',
+        '//*[@method=\'setTemplate\']',
+        '//*[@method=\'setDataUsingMethod\']//*[contains(translate(text(),
+        \'ABCDEFGHIJKLMNOPQRSTUVWXYZ\', \'abcdefghijklmnopqrstuvwxyz\'), \'template\')]/../*',
+    );
+
+    /**
+     * @var string
+     */
+    protected $_xpathBlockValidationExpression = '';
+
+    /**
+     * Disallowed template name
+     *
+     * @var array
+     */
+    protected $_disallowedBlock = array();
+
+    /**
+     * Protected expressions
+     *
+     * @var array
+     */
+    protected $_protectedExpressions = array(
+        self::PROTECTED_ATTR_HELPER_IN_TAG_ACTION_VAR => '//action/*[@helper]',
+    );
+
+    /**
+     * Construct
+     */
+    public function __construct()
+    {
+        $this->_initMessageTemplates();
+        $this->getDisallowedBlocks();
+    }
+
+    /**
+     * Initialize messages templates with translating
+     *
+     * @return Mage_Core_Model_Layout_Validator
+     */
+    protected function _initMessageTemplates()
+    {
+        if (!$this->_messageTemplates) {
+            $this->_messageTemplates = array(
+                self::PROTECTED_ATTR_HELPER_IN_TAG_ACTION_VAR =>
+                    Mage::helper('core')->__('Helper attributes should not be used in custom layout updates.'),
+                self::XML_INVALID => Mage::helper('core')->__('XML data is invalid.'),
+                self::INVALID_TEMPLATE_PATH => Mage::helper('core')->__(
+                    'Invalid template path used in layout update.'
+                ),
+                self::INVALID_BLOCK_NAME => Mage::helper('core')->__('Disallowed block name for frontend.'),
+                self::INVALID_XML_OBJECT_EXCEPTION =>
+                    Mage::helper('core')->__('XML object is not instance of "Varien_Simplexml_Element".'),
+            );
+        }
+        return $this;
+    }
+
+    /**
+     * @return array
+     */
+    public function getDisallowedBlocks()
+    {
+        if (!count($this->_disallowedBlock)) {
+            $disallowedBlockConfig = $this->_getDisallowedBlockConfigValue();
+            if (is_array($disallowedBlockConfig)) {
+                foreach ($disallowedBlockConfig as $blockName => $value) {
+                    $this->_disallowedBlock[] = $blockName;
+                }
+            }
+        }
+        return $this->_disallowedBlock;
+    }
+
+    /**
+     * @return mixed
+     */
+    protected function _getDisallowedBlockConfigValue()
+    {
+        return Mage::getStoreConfig(self::XML_PATH_LAYOUT_DISALLOWED_BLOCKS);
+    }
+
+    /**
+     * Returns true if and only if $value meets the validation requirements
+     *
+     * If $value fails validation, then this method returns false, and
+     * getMessages() will return an array of messages that explain why the
+     * validation failed.
+     *
+     * @throws Exception            Throw exception when xml object is not
+     *                              instance of Varien_Simplexml_Element
+     * @param Varien_Simplexml_Element|string $value
+     * @return bool
+     */
+    public function isValid($value)
+    {
+        if (is_string($value)) {
+            $value = trim($value);
+            try {
+                $value = new Varien_Simplexml_Element('<config>' . $value . '</config>');
+            } catch (Exception $e) {
+                $this->_error(self::XML_INVALID);
+                return false;
+            }
+        } elseif (!($value instanceof Varien_Simplexml_Element)) {
+            throw new Exception($this->_messageTemplates[self::INVALID_XML_OBJECT_EXCEPTION]);
+        }
+        if ($value->xpath($this->getXpathBlockValidationExpression())) {
+            $this->_error(self::INVALID_BLOCK_NAME);
+            return false;
+        }
+        // if layout update declare custom templates then validate their paths
+        if ($templatePaths = $value->xpath($this->getXpathValidationExpression())) {
+            try {
+                $this->validateTemplatePath($templatePaths);
+            } catch (Exception $e) {
+                $this->_error(self::INVALID_TEMPLATE_PATH);
+                return false;
+            }
+        }
+        $this->_setValue($value);
+
+        foreach ($this->_protectedExpressions as $key => $xpr) {
+            if ($this->_value->xpath($xpr)) {
+                $this->_error($key);
+                return false;
+            }
+        }
+        return true;
+    }
+
+    /**
+     * @return array
+     */
+    public function getProtectedExpressions()
+    {
+        return $this->_protectedExpressions;
+    }
+
+    /**
+     * Returns xPath for validate incorrect path to template
+     *
+     * @return string xPath for validate incorrect path to template
+     */
+    public function getXpathValidationExpression()
+    {
+        return implode(" | ", $this->_disallowedXPathExpressions);
+    }
+
+    /**
+     * @return array
+     */
+    public function getDisallowedXpathValidationExpression()
+    {
+        return $this->_disallowedXPathExpressions;
+    }
+
+    /**
+     * Returns xPath for validate incorrect block name
+     *
+     * @return string xPath for validate incorrect block name
+     */
+    public function getXpathBlockValidationExpression()
+    {
+        if (!$this->_xpathBlockValidationExpression) {
+            if (count($this->_disallowedBlock)) {
+                foreach ($this->_disallowedBlock as $key => $value) {
+                    $this->_xpathBlockValidationExpression .= $key > 0 ? " | " : '';
+                    $this->_xpathBlockValidationExpression .=
+                        "//block[translate(@type, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = ";
+                    $this->_xpathBlockValidationExpression .=
+                        "translate('$value', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')]";
+                }
+            }
+        }
+        return $this->_xpathBlockValidationExpression;
+    }
+
+    /**
+     * Validate template path for preventing access to the directory above
+     * If template path value has "../"
+     *
+     * @throws Exception
+     *
+     * @param $templatePaths | array
+     */
+    public function validateTemplatePath(array $templatePaths)
+    {
+        /** @var $path Varien_Simplexml_Element */
+        foreach ($templatePaths as $path) {
+            if ($path->hasChildren()) {
+                $path = stripcslashes(trim((string) $path->children(), '"'));
+            }
+            if (strpos($path, '..' . DS) !== false) {
+                throw new Exception();
+            }
+        }
+    }
+}
diff --git app/code/core/Mage/Core/Model/Resource/File/Storage/Database.php app/code/core/Mage/Core/Model/Resource/File/Storage/Database.php
index d7ef1d5315e..79fecb4e0cd 100644
--- app/code/core/Mage/Core/Model/Resource/File/Storage/Database.php
+++ app/code/core/Mage/Core/Model/Resource/File/Storage/Database.php
@@ -71,7 +71,7 @@ class Mage_Core_Model_Resource_File_Storage_Database extends Mage_Core_Model_Res
                 'nullable' => false,
                 'default' => Varien_Db_Ddl_Table::TIMESTAMP_INIT
                 ), 'Upload Timestamp')
-            ->addColumn('filename', Varien_Db_Ddl_Table::TYPE_TEXT, 100, array(
+            ->addColumn('filename', Varien_Db_Ddl_Table::TYPE_TEXT, 255, array(
                 'nullable' => false
                 ), 'Filename')
             ->addColumn('directory_id', Varien_Db_Ddl_Table::TYPE_INTEGER, null, array(
diff --git app/code/core/Mage/Core/etc/config.xml app/code/core/Mage/Core/etc/config.xml
index b5690704869..7b3910aceb9 100644
--- app/code/core/Mage/Core/etc/config.xml
+++ app/code/core/Mage/Core/etc/config.xml
@@ -28,7 +28,7 @@
 <config>
     <modules>
         <Mage_Core>
-            <version>1.6.0.4.1.3</version>
+            <version>1.6.0.10</version>
         </Mage_Core>
     </modules>
     <global>
@@ -399,6 +399,7 @@
             <security>
                 <use_form_key>1</use_form_key>
                 <extensions_compatibility_mode>1</extensions_compatibility_mode>
+                <secure_system_configuration_save_disabled>0</secure_system_configuration_save_disabled>
             </security>
         </admin>
         <general>
@@ -458,6 +459,13 @@
                 <admin_user_create></admin_user_create>
             </additional_notification_emails>
         </general>
+        <validators>
+            <custom_layout>
+                <disallowed_block>
+                    <Mage_Core_Block_Template_Zend/>
+                </disallowed_block>
+            </custom_layout>
+        </validators>
     </default>
     <stores>
         <default>
diff --git app/code/core/Mage/Core/etc/jstranslator.xml app/code/core/Mage/Core/etc/jstranslator.xml
index 3e138ca2159..923c3ed5e61 100644
--- app/code/core/Mage/Core/etc/jstranslator.xml
+++ app/code/core/Mage/Core/etc/jstranslator.xml
@@ -82,10 +82,10 @@
         <message>Please use only visible characters and spaces.</message>
     </validate-email-sender>
     <validate-password translate="message" module="core">
-        <message>Please enter 6 or more characters. Leading or trailing spaces will be ignored.</message>
+        <message>Please enter more characters or clean leading or trailing spaces.</message>
     </validate-password>
     <validate-admin-password translate="message" module="core">
-        <message>Please enter 7 or more characters. Password should contain both numeric and alphabetic characters.</message>
+        <message>Please enter more characters. Password should contain both numeric and alphabetic characters.</message>
     </validate-admin-password>
     <validate-cpassword translate="message" module="core">
         <message>Please make sure your passwords match.</message>
@@ -130,7 +130,7 @@
         <message>Please select State/Province.</message>
     </validate-state>
     <validate-new-password translate="message" module="core">
-        <message>Please enter 6 or more characters. Leading or trailing spaces will be ignored.</message>
+        <message>Please enter more characters or clean leading or trailing spaces.</message>
     </validate-new-password>
     <validate-greater-than-zero translate="message" module="core">
         <message>Please enter a number greater than 0 in this field.</message>
diff --git app/code/core/Mage/Core/etc/system.xml app/code/core/Mage/Core/etc/system.xml
index 2987e18c803..983cabf2a5d 100644
--- app/code/core/Mage/Core/etc/system.xml
+++ app/code/core/Mage/Core/etc/system.xml
@@ -119,6 +119,7 @@
                     <show_in_default>1</show_in_default>
                     <show_in_website>1</show_in_website>
                     <show_in_store>1</show_in_store>
+                    <dynamic_group>1</dynamic_group>
                 </modules_disable_output>
             </groups>
         </advanced>
diff --git app/code/core/Mage/Core/sql/core_setup/upgrade-1.6.0.8-1.6.0.9.php app/code/core/Mage/Core/sql/core_setup/upgrade-1.6.0.8-1.6.0.9.php
new file mode 100644
index 00000000000..d43552d82d6
--- /dev/null
+++ app/code/core/Mage/Core/sql/core_setup/upgrade-1.6.0.8-1.6.0.9.php
@@ -0,0 +1,35 @@
+<?php
+/**
+ * Magento
+ *
+ * NOTICE OF LICENSE
+ *
+ * This source file is subject to the Open Software License (OSL 3.0)
+ * that is bundled with this package in the file LICENSE.txt.
+ * It is also available through the world-wide-web at this URL:
+ * http://opensource.org/licenses/osl-3.0.php
+ * If you did not receive a copy of the license and are unable to
+ * obtain it through the world-wide-web, please send an email
+ * to license@magento.com so we can send you a copy immediately.
+ *
+ * DISCLAIMER
+ *
+ * Do not edit or add to this file if you wish to upgrade Magento to newer
+ * versions in the future. If you wish to customize Magento for your
+ * needs please refer to http://www.magento.com for more information.
+ *
+ * @category    Mage
+ * @package     Mage_Core
+ * @copyright  Copyright (c) 2006-2019 Magento, Inc. (http://www.magento.com)
+ * @license    http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
+ */
+
+/* @var $installer Mage_Core_Model_Resource_Setup */
+$installer = $this;
+
+$installer->startSetup();
+$connection = $installer->getConnection();
+
+$connection->addColumn($installer->getTable('core_config_data'), 'updated_at', Varien_Db_Ddl_Table::TYPE_TIMESTAMP);
+
+$installer->endSetup();
diff --git app/code/core/Mage/Core/sql/core_setup/upgrade-1.6.0.9-1.6.0.10.php app/code/core/Mage/Core/sql/core_setup/upgrade-1.6.0.9-1.6.0.10.php
new file mode 100644
index 00000000000..b56a7dda9af
--- /dev/null
+++ app/code/core/Mage/Core/sql/core_setup/upgrade-1.6.0.9-1.6.0.10.php
@@ -0,0 +1,48 @@
+<?php
+/**
+ * Magento
+ *
+ * NOTICE OF LICENSE
+ *
+ * This source file is subject to the Open Software License (OSL 3.0)
+ * that is bundled with this package in the file LICENSE.txt.
+ * It is also available through the world-wide-web at this URL:
+ * http://opensource.org/licenses/osl-3.0.php
+ * If you did not receive a copy of the license and are unable to
+ * obtain it through the world-wide-web, please send an email
+ * to license@magento.com so we can send you a copy immediately.
+ *
+ * DISCLAIMER
+ *
+ * Do not edit or add to this file if you wish to upgrade Magento to newer
+ * versions in the future. If you wish to customize Magento for your
+ * needs please refer to http://www.magento.com for more information.
+ *
+ * @category    Mage
+ * @package     Mage_Core
+ * @copyright  Copyright (c) 2006-2019 Magento, Inc. (http://www.magento.com)
+ * @license    http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
+ */
+
+/* @var $installer Mage_Core_Model_Resource_Setup */
+$installer = $this;
+$installer->startSetup();
+$table = $installer->getTable('core/file_storage');
+
+/**
+ * Change column
+ */
+if ($installer->getConnection()->isTableExists($table)) {
+    $installer->getConnection()->modifyColumn(
+        $table,
+        'filename',
+        array(
+            'type' => Varien_Db_Ddl_Table::TYPE_TEXT,
+            'length' => 255,
+            'nullable' => false,
+            'comment' => 'Filename',
+        )
+    );
+}
+
+$installer->endSetup();
diff --git app/code/core/Mage/Customer/Block/Account/Changeforgotten.php app/code/core/Mage/Customer/Block/Account/Changeforgotten.php
index 9c08a7dc2bc..8b6120e7742 100644
--- app/code/core/Mage/Customer/Block/Account/Changeforgotten.php
+++ app/code/core/Mage/Customer/Block/Account/Changeforgotten.php
@@ -34,5 +34,13 @@
 
 class Mage_Customer_Block_Account_Changeforgotten extends Mage_Core_Block_Template
 {
-
+    /**
+     * Retrieve minimum length of customer password
+     *
+     * @return int
+     */
+    public function getMinPasswordLength()
+    {
+        return Mage::getModel('customer/customer')->getMinPasswordLength();
+    }
 }
diff --git app/code/core/Mage/Customer/Block/Address/Renderer/Default.php app/code/core/Mage/Customer/Block/Address/Renderer/Default.php
index 9780413613b..cd193541159 100644
--- app/code/core/Mage/Customer/Block/Address/Renderer/Default.php
+++ app/code/core/Mage/Customer/Block/Address/Renderer/Default.php
@@ -70,7 +70,13 @@ class Mage_Customer_Block_Address_Renderer_Default
         $countryFormat = is_null($address)
             ? false
             : $address->getCountryModel()->getFormat($this->getType()->getCode());
-        $format = $countryFormat ? $countryFormat->getFormat() : $this->getType()->getDefaultFormat();
+        if ($countryFormat) {
+            $format = $countryFormat->getFormat();
+        } else {
+            $regExp = "/^[^()\n]*+(\((?>[^()\n]|(?1))*+\)[^()\n]*+)++$|^[^()]+?$/m";
+            preg_match_all($regExp, $this->getType()->getDefaultFormat(), $matches, PREG_SET_ORDER);
+            $format = count($matches) ? $this->_prepareAddressTemplateData($this->getType()->getDefaultFormat()) : null;
+        }
         return $format;
     }
 
@@ -132,9 +138,25 @@ class Mage_Customer_Block_Address_Renderer_Default
         }
 
         $formater->setVariables($data);
-
-        $format = !is_null($format) ? $format : $this->getFormat($address);
+        $format = !is_null($format) ? $format : $this->_prepareAddressTemplateData($this->getFormat($address));
 
         return $formater->filter($format);
     }
+
+    /**
+     * Get address template data without url and js code
+     * @param $data
+     * @return string
+     */
+    protected function _prepareAddressTemplateData($data)
+    {
+        $result = '';
+        if (is_string($data)) {
+            $urlRegExp = "@(https?://([-\w\.]+[-\w])+(:\d+)?(/([\w/_\.#-]*(\?\S+)?[^\.\s])?)?)@";
+            /** @var $maliciousCodeFilter Mage_Core_Model_Input_Filter_MaliciousCode */
+            $maliciousCodeFilter = Mage::getSingleton('core/input_filter_maliciousCode');
+            $result = preg_replace($urlRegExp, ' ', $maliciousCodeFilter->filter($data));
+        }
+        return $result;
+    }
 }
diff --git app/code/core/Mage/Customer/Block/Form/Register.php app/code/core/Mage/Customer/Block/Form/Register.php
index 2294e59ba58..97584870458 100644
--- app/code/core/Mage/Customer/Block/Form/Register.php
+++ app/code/core/Mage/Customer/Block/Form/Register.php
@@ -161,4 +161,14 @@ class Mage_Customer_Block_Form_Register extends Mage_Directory_Block_Data
 
         return $this;
     }
+
+    /**
+     * Retrieve minimum length of customer password
+     *
+     * @return int
+     */
+    public function getMinPasswordLength()
+    {
+        return Mage::getModel('customer/customer')->getMinPasswordLength();
+    }
 }
diff --git app/code/core/Mage/Customer/Model/Customer.php app/code/core/Mage/Customer/Model/Customer.php
index 1d404dc6ef9..046479c6586 100644
--- app/code/core/Mage/Customer/Model/Customer.php
+++ app/code/core/Mage/Customer/Model/Customer.php
@@ -48,6 +48,17 @@ class Mage_Customer_Model_Customer extends Mage_Core_Model_Abstract
     const XML_PATH_GENERATE_HUMAN_FRIENDLY_ID   = 'customer/create_account/generate_human_friendly_id';
     /**#@-*/
 
+    /**
+     * Minimum Password Length
+     * @deprecated Use getMinPasswordLength() method instead
+     */
+    const MINIMUM_PASSWORD_LENGTH = Mage_Core_Model_App::ABSOLUTE_MIN_PASSWORD_LENGTH;
+
+    /**
+     * Configuration path for minimum length of password
+     */
+    const XML_PATH_MIN_PASSWORD_LENGTH = 'customer/password/min_password_length';
+
     /**
      * Maximum Password Length
      */
@@ -390,7 +401,7 @@ class Mage_Customer_Model_Customer extends Mage_Core_Model_Abstract
     public function hashPassword($password, $salt = null)
     {
         return $this->_getHelper('core')
-            ->getHash($password, !is_null($salt) ? $salt : Mage_Admin_Model_User::HASH_SALT_LENGTH);
+            ->getHashPassword(trim($password), (bool) $salt ? $salt : Mage_Admin_Model_User::HASH_SALT_LENGTH);
     }
 
     /**
@@ -412,6 +423,10 @@ class Mage_Customer_Model_Customer extends Mage_Core_Model_Abstract
      */
     public function generatePassword($length = 8)
     {
+        $minPasswordLength = $this->getMinPasswordLength();
+        if ($minPasswordLength > $length) {
+            $length = $minPasswordLength;
+        }
         $chars = Mage_Core_Helper_Data::CHARS_PASSWORD_LOWERS
             . Mage_Core_Helper_Data::CHARS_PASSWORD_UPPERS
             . Mage_Core_Helper_Data::CHARS_PASSWORD_DIGITS
@@ -843,8 +858,9 @@ class Mage_Customer_Model_Customer extends Mage_Core_Model_Abstract
         if (!$this->getId() && !Zend_Validate::is($password , 'NotEmpty')) {
             $errors[] = Mage::helper('customer')->__('The password cannot be empty.');
         }
-        if (strlen($password) && !Zend_Validate::is($password, 'StringLength', array(6))) {
-            $errors[] = Mage::helper('customer')->__('The minimum password length is %s', 6);
+        $minPasswordLength = $this->getMinPasswordLength();
+        if (strlen($password) && !Zend_Validate::is($password, 'StringLength', array($minPasswordLength))) {
+            $errors[] = Mage::helper('customer')->__('The minimum password length is %s', $minPasswordLength);
         }
         if (strlen($password) && !Zend_Validate::is($password, 'StringLength', array('max' => self::MAXIMUM_PASSWORD_LENGTH))) {
             $errors[] = Mage::helper('customer')
@@ -1377,4 +1393,16 @@ class Mage_Customer_Model_Customer extends Mage_Core_Model_Abstract
 
         return false;
     }
+
+    /**
+     * Retrieve minimum length of password
+     *
+     * @return int
+     */
+    public function getMinPasswordLength()
+    {
+        $minLength = (int)Mage::getStoreConfig(self::XML_PATH_MIN_PASSWORD_LENGTH);
+        $absoluteMinLength = Mage_Core_Model_App::ABSOLUTE_MIN_PASSWORD_LENGTH;
+        return ($minLength < $absoluteMinLength) ? $absoluteMinLength : $minLength;
+    }
 }
diff --git app/code/core/Mage/Customer/Model/Customer/Attribute/Backend/Password.php app/code/core/Mage/Customer/Model/Customer/Attribute/Backend/Password.php
index 85f3e870149..b9decdff47d 100644
--- app/code/core/Mage/Customer/Model/Customer/Attribute/Backend/Password.php
+++ app/code/core/Mage/Customer/Model/Customer/Attribute/Backend/Password.php
@@ -43,8 +43,12 @@ class Mage_Customer_Model_Customer_Attribute_Backend_Password extends Mage_Eav_M
         $password = trim($object->getPassword());
         $len = Mage::helper('core/string')->strlen($password);
         if ($len) {
-             if ($len < 6) {
-                Mage::throwException(Mage::helper('customer')->__('The password must have at least 6 characters. Leading or trailing spaces will be ignored.'));
+            $minPasswordLength = Mage::getModel('customer/customer')->getMinPasswordLength();
+            if ($len < $minPasswordLength) {
+                Mage::throwException(Mage::helper('customer')->__(
+                    'The password must have at least %d characters. Leading or trailing spaces will be ignored.',
+                    $minPasswordLength
+                ));
             }
             $object->setPasswordHash($object->hashPassword($password));
         }
diff --git app/code/core/Mage/Customer/controllers/AccountController.php app/code/core/Mage/Customer/controllers/AccountController.php
index b91d07225b7..d57366fb3ce 100644
--- app/code/core/Mage/Customer/controllers/AccountController.php
+++ app/code/core/Mage/Customer/controllers/AccountController.php
@@ -970,14 +970,7 @@ class Mage_Customer_AccountController extends Mage_Core_Controller_Front_Action
                     $newPass    = $this->getRequest()->getPost('password');
                     $confPass   = $this->getRequest()->getPost('confirmation');
 
-                    $oldPass = $this->_getSession()->getCustomer()->getPasswordHash();
-                    if ( $this->_getHelper('core/string')->strpos($oldPass, ':')) {
-                        list($_salt, $salt) = explode(':', $oldPass);
-                    } else {
-                        $salt = false;
-                    }
-
-                    if ($customer->hashPassword($currPass, $salt) == $oldPass) {
+                    if ($customer->validatePassword($currPass)) {
                         if (strlen($newPass)) {
                             /**
                              * Set entered password and its confirmation - they
diff --git app/code/core/Mage/Customer/etc/config.xml app/code/core/Mage/Customer/etc/config.xml
index 870f9105755..eb3253be7d9 100644
--- app/code/core/Mage/Customer/etc/config.xml
+++ app/code/core/Mage/Customer/etc/config.xml
@@ -520,6 +520,7 @@
                 <forgot_email_template>customer_password_forgot_email_template</forgot_email_template>
                 <remind_email_template>customer_password_remind_email_template</remind_email_template>
                 <reset_link_expiration_period>1</reset_link_expiration_period>
+                <min_password_length>7</min_password_length>
             </password>
             <address>
                 <street_lines>2</street_lines>
@@ -575,5 +576,10 @@ T: {{var telephone}}
                 <js_template><![CDATA[#{prefix} #{firstname} #{middlename} #{lastname} #{suffix}<br/>#{company}<br/>#{street0}<br/>#{street1}<br/>#{street2}<br/>#{street3}<br/>#{city}, #{region}, #{postcode}<br/>#{country_id}<br/>T: #{telephone}<br/>F: #{fax}<br/>VAT: #{vat_id}]]></js_template>
             </address_templates>
         </customer>
+        <admin>
+            <security>
+                <min_admin_password_length>14</min_admin_password_length>
+            </security>
+        </admin>
     </default>
 </config>
diff --git app/code/core/Mage/Customer/etc/system.xml app/code/core/Mage/Customer/etc/system.xml
index 8328b2d2029..ce02ced58c2 100644
--- app/code/core/Mage/Customer/etc/system.xml
+++ app/code/core/Mage/Customer/etc/system.xml
@@ -296,6 +296,17 @@
                             <show_in_website>0</show_in_website>
                             <show_in_store>0</show_in_store>
                         </reset_link_expiration_period>
+                        <min_password_length translate="label comment">
+                            <label>Minimum password length</label>
+                            <comment>Please enter a number 7 or greater in this field.</comment>
+                            <frontend_type>text</frontend_type>
+                            <validate>required-entry validate-digits validate-digits-range digits-range-7-</validate>
+                            <backend_model>adminhtml/system_config_backend_passwordlength</backend_model>
+                            <sort_order>60</sort_order>
+                            <show_in_default>1</show_in_default>
+                            <show_in_website>0</show_in_website>
+                            <show_in_store>0</show_in_store>
+                        </min_password_length>
                     </fields>
                 </password>
                 <address translate="label">
@@ -483,5 +494,24 @@
                 </store_information>
             </groups>
         </general>
+        <admin>
+            <groups>
+                <security>
+                    <fields>
+                        <min_admin_password_length translate="label comment">
+                            <label>Minimum admin password length</label>
+                            <comment>Please enter a number 7 or greater in this field.</comment>
+                            <frontend_type>text</frontend_type>
+                            <validate>required-entry validate-digits validate-digits-range digits-range-7-</validate>
+                            <backend_model>adminhtml/system_config_backend_passwordlength</backend_model>
+                            <sort_order>170</sort_order>
+                            <show_in_default>1</show_in_default>
+                            <show_in_website>0</show_in_website>
+                            <show_in_store>0</show_in_store>
+                        </min_admin_password_length>
+                    </fields>
+                </security>
+            </groups>
+        </admin>
     </sections>
 </config>
diff --git app/code/core/Mage/Dataflow/Model/Convert/Container/Abstract.php app/code/core/Mage/Dataflow/Model/Convert/Container/Abstract.php
index 5086f9d3062..620288687af 100644
--- app/code/core/Mage/Dataflow/Model/Convert/Container/Abstract.php
+++ app/code/core/Mage/Dataflow/Model/Convert/Container/Abstract.php
@@ -55,9 +55,7 @@ abstract class Mage_Dataflow_Model_Convert_Container_Abstract
      */
     protected function isSerialized($data)
     {
-        $pattern =
-            '/^a:\d+:\{(i:\d+;|s:\d+:\".+\";|N;|O:\d+:\"\w+\":\d+:\{\w:\d+:)+|^O:\d+:\"\w+\":\d+:\{(s:\d+:\"|i:\d+;)/';
-        return (is_string($data) && preg_match($pattern, $data));
+        return Mage::helper('core/string')->isSerializedArrayOrObject($data);
     }
 
     public function getVar($key, $default=null)
diff --git app/code/core/Mage/Dataflow/Model/Convert/Parser/Csv.php app/code/core/Mage/Dataflow/Model/Convert/Parser/Csv.php
index 66c45eedfba..2a36b3c7849 100644
--- app/code/core/Mage/Dataflow/Model/Convert/Parser/Csv.php
+++ app/code/core/Mage/Dataflow/Model/Convert/Parser/Csv.php
@@ -71,6 +71,7 @@ class Mage_Dataflow_Model_Convert_Parser_Csv extends Mage_Dataflow_Model_Convert
         if (!method_exists($adapter, $adapterMethod)) {
             $message = Mage::helper('dataflow')
                 ->__('Method "%s" not defined in adapter %s.', $adapterMethod, $adapterName);
+            $message = Mage::helper('dataflow')->escapeHtml($message);
             $this->addException($message, Mage_Dataflow_Model_Convert_Exception::FATAL);
             return $this;
         }
diff --git app/code/core/Mage/Dataflow/Model/Convert/Parser/Xml/Excel.php app/code/core/Mage/Dataflow/Model/Convert/Parser/Xml/Excel.php
index 57e26c0eb40..f793c03130b 100644
--- app/code/core/Mage/Dataflow/Model/Convert/Parser/Xml/Excel.php
+++ app/code/core/Mage/Dataflow/Model/Convert/Parser/Xml/Excel.php
@@ -71,6 +71,7 @@ class Mage_Dataflow_Model_Convert_Parser_Xml_Excel extends Mage_Dataflow_Model_C
         if (!method_exists($adapter, $adapterMethod)) {
             $message = Mage::helper('dataflow')
                 ->__('Method "%s" was not defined in adapter %s.', $adapterMethod, $adapterName);
+            $message = Mage::helper('dataflow')->escapeHtml($message);
             $this->addException($message, Mage_Dataflow_Model_Convert_Exception::FATAL);
             return $this;
         }
diff --git app/code/core/Mage/Dataflow/Model/Profile.php app/code/core/Mage/Dataflow/Model/Profile.php
index 98b30d4926a..3a9034323cb 100644
--- app/code/core/Mage/Dataflow/Model/Profile.php
+++ app/code/core/Mage/Dataflow/Model/Profile.php
@@ -57,6 +57,20 @@ class Mage_Dataflow_Model_Profile extends Mage_Core_Model_Abstract
     const DEFAULT_EXPORT_PATH = 'var/export';
     const DEFAULT_EXPORT_FILENAME = 'export_';
 
+    /**
+     * Product table permanent attributes
+     *
+     * @var array
+     */
+    protected $_productTablePermanentAttributes = array('sku');
+
+    /**
+     * Customer table permanent attributes
+     *
+     * @var array
+     */
+    protected $_customerTablePermanentAttributes = array('email', 'website');
+
     protected function _construct()
     {
         $this->_init('dataflow/profile');
@@ -151,6 +165,9 @@ class Mage_Dataflow_Model_Profile extends Mage_Core_Model_Abstract
             ->setProfileId($this->getId())
             ->setActionCode($this->getOrigData('profile_id') ? 'update' : 'create')
             ->save();
+        $csvParser = new Varien_File_Csv();
+        $xmlParser = new DOMDocument();
+        $newUploadedFilenames = array();
 
         if (isset($_FILES['file_1']['tmp_name']) || isset($_FILES['file_2']['tmp_name'])
         || isset($_FILES['file_3']['tmp_name'])) {
@@ -160,9 +177,58 @@ class Mage_Dataflow_Model_Profile extends Mage_Core_Model_Abstract
                     $uploader->setAllowedExtensions(array('csv','xml'));
                     $path = Mage::app()->getConfig()->getTempVarDir() . '/import/';
                     $uploader->save($path);
-                    if ($uploadFile = $uploader->getUploadedFileName()) {
+                    $uploadFile = $uploader->getUploadedFileName();
+
+                    if ($_FILES['file_' . ($index + 1)]['type'] == "text/csv") {
+                        $fileData = $csvParser->getData($path . $uploadFile);
+                        $fileData = array_shift($fileData);
+                    } else {
+                        try {
+                            $xmlParser->loadXML(file_get_contents($path . $uploadFile));
+                            $cells = $this->getNode($xmlParser, 'Worksheet')->item(0);
+                            $cells = $this->getNode($cells, 'Row')->item(0);
+                            $cells = $this->getNode($cells, 'Cell');
+                            $fileData = array();
+                            foreach ($cells as $cell) {
+                                $fileData[] = $this->getNode($cell, 'Data')->item(0)->nodeValue;
+                            }
+                        } catch (Exception $e) {
+                            foreach ($newUploadedFilenames as $k => $v) {
+                                unlink($path . $v);
+                            }
+                            unlink($path . $uploadFile);
+                            Mage::throwException(
+                                Mage::helper('Dataflow')->__(
+                                    'Upload failed. Wrong data format in file: %s.',
+                                    $uploadFile
+                                )
+                            );
+                        }
+                    }
+
+                    if ($this->_data['entity_type'] == 'customer') {
+                        $attributes = $this->_customerTablePermanentAttributes;
+                    } else {
+                        $attributes = $this->_productTablePermanentAttributes;
+                    }
+                    $colsAbsent = array_diff($attributes, $fileData);
+                    if ($colsAbsent) {
+                        foreach ($newUploadedFilenames as $k => $v) {
+                            unlink($path . $v);
+                        }
+                        unlink($path . $uploadFile);
+                        Mage::throwException(
+                            Mage::helper('Dataflow')->__(
+                                'Upload failed. Can not find required columns: %s in file %s.',
+                                implode(', ', $colsAbsent),
+                                $uploadFile
+                            )
+                        );
+                    }
+                    if ($uploadFile) {
                         $newFilename = 'import-' . date('YmdHis') . '-' . ($index+1) . '_' . $uploadFile;
                         rename($path . $uploadFile, $path . $newFilename);
+                        $newUploadedFilenames[] = $newFilename;
                     }
                 }
                 //BOM deleting for UTF files
@@ -431,4 +497,20 @@ echo "<xmp>" . $xml . "</xmp>";
 die;*/
         return $this;
     }
+
+    /**
+     * Get node from xml object
+     *
+     * @param object $xmlObject
+     * @param string $nodeName
+     * @return object
+     * @throws Exception
+     */
+    protected function getNode($xmlObject, $nodeName)
+    {
+        if ($xmlObject != null) {
+            return $xmlObject->getElementsByTagName($nodeName);
+        }
+        Mage::throwException(Mage::helper('Dataflow')->__('Invalid node.'));
+    }
 }
diff --git app/code/core/Mage/Eav/Model/Entity/Attribute/Backend/Abstract.php app/code/core/Mage/Eav/Model/Entity/Attribute/Backend/Abstract.php
index e4f74de9f28..fe56e6ba18c 100644
--- app/code/core/Mage/Eav/Model/Entity/Attribute/Backend/Abstract.php
+++ app/code/core/Mage/Eav/Model/Entity/Attribute/Backend/Abstract.php
@@ -246,6 +246,15 @@ abstract class Mage_Eav_Model_Entity_Attribute_Backend_Abstract
             return false;
         }
 
+        //Validate serialized data
+        if (!Mage::helper('core/string')->validateSerializedObject($value)) {
+            $label = $this->getAttribute()->getFrontend()->getLabel();
+            throw Mage::exception(
+                'Mage_Eav',
+                Mage::helper('eav')->__('The value of attribute "%s" contains invalid data.', $label)
+            );
+        }
+
         if ($this->getAttribute()->getIsUnique()
             && !$this->getAttribute()->getIsRequired()
             && ($value == '' || $this->getAttribute()->isValueEmpty($value)))
diff --git app/code/core/Mage/ImportExport/Model/Import/Adapter/Abstract.php app/code/core/Mage/ImportExport/Model/Import/Adapter/Abstract.php
index 9de194c58cd..9ab4ff700a0 100644
--- app/code/core/Mage/ImportExport/Model/Import/Adapter/Abstract.php
+++ app/code/core/Mage/ImportExport/Model/Import/Adapter/Abstract.php
@@ -174,4 +174,14 @@ abstract class Mage_ImportExport_Model_Import_Adapter_Abstract implements Seekab
     {
         return $this;
     }
+
+    /**
+     * Get the source path
+     *
+     * @return string
+     */
+    public function getSource()
+    {
+        return $this->_source;
+    }
 }
diff --git app/code/core/Mage/ImportExport/Model/Import/Entity/Abstract.php app/code/core/Mage/ImportExport/Model/Import/Entity/Abstract.php
index de543556338..8f9471a4f58 100644
--- app/code/core/Mage/ImportExport/Model/Import/Entity/Abstract.php
+++ app/code/core/Mage/ImportExport/Model/Import/Entity/Abstract.php
@@ -669,6 +669,7 @@ abstract class Mage_ImportExport_Model_Import_Entity_Abstract
         if (!$this->_dataValidated) {
             // does all permanent columns exists?
             if (($colsAbsent = array_diff($this->_permanentAttributes, $this->_getSource()->getColNames()))) {
+                file_put_contents($this->_getSource()->getSource(), "");
                 Mage::throwException(
                     Mage::helper('importexport')->__('Can not find required columns: %s', implode(', ', $colsAbsent))
                 );
diff --git app/code/core/Mage/Install/Block/Admin.php app/code/core/Mage/Install/Block/Admin.php
index 72d2e2e32a8..8d1f88f8f57 100644
--- app/code/core/Mage/Install/Block/Admin.php
+++ app/code/core/Mage/Install/Block/Admin.php
@@ -51,4 +51,14 @@ class Mage_Install_Block_Admin extends Mage_Install_Block_Abstract
         }
         return $data;
     }
+
+    /**
+     * Retrieve minimum length of admin password
+     *
+     * @return int
+     */
+    public function getMinAdminPasswordLength()
+    {
+        return Mage::getModel('admin/user')->getMinAdminPasswordLength();
+    }
 }
diff --git app/code/core/Mage/Install/etc/config.xml app/code/core/Mage/Install/etc/config.xml
index 86c9335098a..9eb4556fe1b 100644
--- app/code/core/Mage/Install/etc/config.xml
+++ app/code/core/Mage/Install/etc/config.xml
@@ -57,6 +57,13 @@
                 </install>
             </routers>
         </web>
+        <validators>
+            <custom_layout>
+                <disallowed_block>
+                    <Mage_Install_Block_End/>
+                </disallowed_block>
+            </custom_layout>
+        </validators>
     </default>
     <stores>
         <default>
diff --git app/code/core/Mage/Review/controllers/ProductController.php app/code/core/Mage/Review/controllers/ProductController.php
index 83335472cfb..5d0cf8c6d26 100644
--- app/code/core/Mage/Review/controllers/ProductController.php
+++ app/code/core/Mage/Review/controllers/ProductController.php
@@ -304,7 +304,17 @@ class Mage_Review_ProductController extends Mage_Core_Controller_Front_Action
             $this->getLayout()->helper('page/layout')
                 ->applyTemplate($product->getPageLayout());
         }
-        $update->addUpdate($product->getCustomLayoutUpdate());
+        $customLayout = $product->getCustomLayoutUpdate();
+        if ($customLayout) {
+            try {
+                if (!Mage::getModel('core/layout_validator')->isValid($customLayout)) {
+                    $customLayout = '';
+                }
+            } catch (Exception $e) {
+                $customLayout = '';
+            }
+        }
+        $update->addUpdate($customLayout);
         $this->generateLayoutXml()->generateLayoutBlocks();
     }
 
diff --git app/code/core/Mage/Rss/etc/config.xml app/code/core/Mage/Rss/etc/config.xml
index d2d5cdc93fe..aa45d93d4ae 100644
--- app/code/core/Mage/Rss/etc/config.xml
+++ app/code/core/Mage/Rss/etc/config.xml
@@ -119,4 +119,13 @@
             </updates>
         </layout>
     </frontend>
+    <default>
+        <validators>
+            <custom_layout>
+                <disallowed_block>
+                    <Mage_Rss_Block_Order_New/>
+                </disallowed_block>
+            </custom_layout>
+        </validators>
+    </default>
 </config>
diff --git app/code/core/Mage/Widget/controllers/Adminhtml/Widget/InstanceController.php app/code/core/Mage/Widget/controllers/Adminhtml/Widget/InstanceController.php
index b2aa7cfed38..5ee05b5eaeb 100644
--- app/code/core/Mage/Widget/controllers/Adminhtml/Widget/InstanceController.php
+++ app/code/core/Mage/Widget/controllers/Adminhtml/Widget/InstanceController.php
@@ -295,6 +295,17 @@ class Mage_Widget_Adminhtml_Widget_InstanceController extends Mage_Adminhtml_Con
         $this->setBody($templateChooser->toHtml());
     }
 
+    /**
+     * Controller predispatch method
+     *
+     * @return Mage_Adminhtml_Controller_Action
+     */
+    public function preDispatch()
+    {
+        $this->_setForcedFormKeyActions('delete');
+        return parent::preDispatch();
+    }
+
     /**
      * Check is allowed access to action
      *
diff --git app/code/core/Mage/Wishlist/Block/Abstract.php app/code/core/Mage/Wishlist/Block/Abstract.php
index 937614fc2c6..0c2c47ed1e1 100644
--- app/code/core/Mage/Wishlist/Block/Abstract.php
+++ app/code/core/Mage/Wishlist/Block/Abstract.php
@@ -168,7 +168,7 @@ abstract class Mage_Wishlist_Block_Abstract extends Mage_Catalog_Block_Product_A
      */
     public function getItemRemoveUrl($item)
     {
-        return $this->_getHelper()->getRemoveUrl($item);
+        return $this->getItemRemoveUrlCustom($item);
     }
 
     /**
@@ -179,7 +179,7 @@ abstract class Mage_Wishlist_Block_Abstract extends Mage_Catalog_Block_Product_A
      */
     public function getItemAddToCartUrl($item)
     {
-        return $this->_getHelper()->getAddToCartUrl($item);
+        return $this->getItemAddToCartUrlCustom($item);
     }
 
     /**
@@ -201,7 +201,7 @@ abstract class Mage_Wishlist_Block_Abstract extends Mage_Catalog_Block_Product_A
      */
     public function getAddToWishlistUrl($product)
     {
-        return $this->_getHelper()->getAddUrl($product);
+        return $this->getAddToWishlistUrlCustom($product);
     }
 
      /**
@@ -408,4 +408,49 @@ abstract class Mage_Wishlist_Block_Abstract extends Mage_Catalog_Block_Product_A
         }
         return parent::getProductUrl($product, $additional);
     }
+
+    /**
+     * Retrieve URL for adding Product to wishlist with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product $product
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getAddToWishlistUrlCustom($product, $addFormKey = true)
+    {
+        if (!$addFormKey) {
+            return $this->_getHelper()->getAddUrlWithCustomParams($product, array(), false);
+        }
+        return $this->_getHelper()->getAddUrl($product);
+    }
+
+    /**
+     * Retrieve URL for Removing item from wishlist with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product|Mage_Wishlist_Model_Item $item
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getItemRemoveUrlCustom($item, $addFormKey = true)
+    {
+        if (!$addFormKey) {
+            return $this->_getHelper()->getRemoveUrlCustom($item, false);
+        }
+        return $this->_getHelper()->getRemoveUrl($item);
+    }
+
+    /**
+     * Retrieve Add Item to shopping cart URL with or without Form Key
+     *
+     * @param string|Mage_Catalog_Model_Product|Mage_Wishlist_Model_Item $item
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getItemAddToCartUrlCustom($item, $addFormKey = true)
+    {
+        if (!$addFormKey) {
+            return $this->_getHelper()->getAddToCartUrlCustom($item, false);
+        }
+        return $this->_getHelper()->getAddToCartUrl($item);
+    }
 }
diff --git app/code/core/Mage/Wishlist/Block/Customer/Wishlist/Item/Column/Cart.php app/code/core/Mage/Wishlist/Block/Customer/Wishlist/Item/Column/Cart.php
index a1805c8fa5f..3565e1a3eea 100644
--- app/code/core/Mage/Wishlist/Block/Customer/Wishlist/Item/Column/Cart.php
+++ app/code/core/Mage/Wishlist/Block/Customer/Wishlist/Item/Column/Cart.php
@@ -54,7 +54,16 @@ class Mage_Wishlist_Block_Customer_Wishlist_Item_Column_Cart extends Mage_Wishli
     {
         $js = "
             function addWItemToCart(itemId) {
-                var url = '" . $this->getItemAddToCartUrl('%item%') . "';
+                addWItemToCartCustom(itemId, true)
+            }
+            
+            function addWItemToCartCustom(itemId, sendGet) {
+                var url = '';
+                if (sendGet) {
+                    url = '" . $this->getItemAddToCartUrl('%item%') . "';
+                } else {
+                    url = '" . $this->getItemAddToCartUrlCustom('%item%', false) . "';
+                }
                 url = url.gsub('%item%', itemId);
                 var form = $('wishlist-view-form');
                 if (form) {
@@ -64,7 +73,11 @@ class Mage_Wishlist_Block_Customer_Wishlist_Item_Column_Cart extends Mage_Wishli
                         url += separator + input.name + '=' + encodeURIComponent(input.value);
                     }
                 }
-                setLocation(url);
+                if (sendGet) {
+                    setLocation(url);
+                } else {
+                    customFormSubmit(url, '" . json_encode(array('form_key' => $this->getFormKey())) . "', 'post');
+                }
             }
         ";
 
diff --git app/code/core/Mage/Wishlist/Block/Item/Configure.php app/code/core/Mage/Wishlist/Block/Item/Configure.php
index 7a6daefc4c4..5a306e7507e 100644
--- app/code/core/Mage/Wishlist/Block/Item/Configure.php
+++ app/code/core/Mage/Wishlist/Block/Item/Configure.php
@@ -65,7 +65,9 @@ class Mage_Wishlist_Block_Item_Configure extends Mage_Core_Block_Template
         $block = $this->getLayout()->getBlock('product.info');
         if ($block) {
             $url = Mage::helper('wishlist')->getAddToCartUrl($this->getWishlistItem());
+            $postUrl = Mage::helper('wishlist')->getAddToCartUrlCustom($this->getWishlistItem(), false);
             $block->setCustomAddToCartUrl($url);
+            $block->setCustomAddToCartPostUrl($postUrl);
         }
 
         return parent::_prepareLayout();
diff --git app/code/core/Mage/Wishlist/Block/Share/Email/Items.php app/code/core/Mage/Wishlist/Block/Share/Email/Items.php
index 12f58eba1d8..a0b3caa9025 100644
--- app/code/core/Mage/Wishlist/Block/Share/Email/Items.php
+++ app/code/core/Mage/Wishlist/Block/Share/Email/Items.php
@@ -66,9 +66,7 @@ class Mage_Wishlist_Block_Share_Email_Items extends Mage_Wishlist_Block_Abstract
      */
     public function getAddToCartUrl($product, $additional = array())
     {
-        $additional['nocookie'] = 1;
-        $additional['_store_to_url'] = true;
-        return parent::getAddToCartUrl($product, $additional);
+        return $this->getAddToCartUrlCustom($product, $additional);
     }
 
     /**
@@ -85,4 +83,19 @@ class Mage_Wishlist_Block_Share_Email_Items extends Mage_Wishlist_Block_Abstract
         }
         return $hasDescription;
     }
+
+    /**
+     * Retrieve URL for add product to shopping cart with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product $product
+     * @param array $additional
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getAddToCartUrlCustom($product, $additional = array(), $addFormKey = true)
+    {
+        $additional['nocookie'] = 1;
+        $additional['_store_to_url'] = true;
+        return parent::getAddToCartUrlCustom($product, $additional, $addFormKey);
+    }
 }
diff --git app/code/core/Mage/Wishlist/Helper/Data.php app/code/core/Mage/Wishlist/Helper/Data.php
index 8c891ae284d..99d04932d05 100644
--- app/code/core/Mage/Wishlist/Helper/Data.php
+++ app/code/core/Mage/Wishlist/Helper/Data.php
@@ -273,12 +273,7 @@ class Mage_Wishlist_Helper_Data extends Mage_Core_Helper_Abstract
      */
     public function getRemoveUrl($item)
     {
-        return $this->_getUrl('wishlist/index/remove',
-            array(
-                'item' => $item->getWishlistItemId(),
-                Mage_Core_Model_Url::FORM_KEY => $this->_getSingletonModel('core/session')->getFormKey()
-            )
-        );
+        return $this->getRemoveUrlCustom($item);
     }
 
     /**
@@ -352,21 +347,7 @@ class Mage_Wishlist_Helper_Data extends Mage_Core_Helper_Abstract
      */
     public function getAddUrlWithParams($item, array $params = array())
     {
-        $productId = null;
-        if ($item instanceof Mage_Catalog_Model_Product) {
-            $productId = $item->getEntityId();
-        }
-        if ($item instanceof Mage_Wishlist_Model_Item) {
-            $productId = $item->getProductId();
-        }
-
-        if ($productId) {
-            $params['product'] = $productId;
-            $params[Mage_Core_Model_Url::FORM_KEY] = $this->_getSingletonModel('core/session')->getFormKey();
-            return $this->_getUrlStore($item)->getUrl('wishlist/index/add', $params);
-        }
-
-        return false;
+        return $this->getAddUrlWithCustomParams($item, $params);
     }
 
     /**
@@ -377,19 +358,7 @@ class Mage_Wishlist_Helper_Data extends Mage_Core_Helper_Abstract
      */
     public function getAddToCartUrl($item)
     {
-        $continueUrl  = $this->_getHelperInstance('core')->urlEncode(
-            $this->_getUrl('*/*/*', array(
-                '_current'      => true,
-                '_use_rewrite'  => true,
-                '_store_to_url' => true,
-            ))
-        );
-        $params = array(
-            'item' => is_string($item) ? $item : $item->getWishlistItemId(),
-            Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED => $continueUrl,
-            Mage_Core_Model_Url::FORM_KEY => $this->_getSingletonModel('core/session')->getFormKey()
-        );
-        return $this->_getUrlStore($item)->getUrl('wishlist/index/cart', $params);
+        return $this->getAddToCartUrlCustom($item);
     }
 
     /**
@@ -592,4 +561,78 @@ class Mage_Wishlist_Helper_Data extends Mage_Core_Helper_Abstract
     {
         return Mage::getStoreConfig(self::XML_PATH_WISHLIST_LINK_USE_QTY);
     }
+
+    /**
+     * Retrieve url for adding product to wishlist with params with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product|Mage_Wishlist_Model_Item $item
+     * @param array $params
+     * @param bool $addFormKey
+     * @return string|bool
+     */
+    public function getAddUrlWithCustomParams($item, array $params = array(), $addFormKey = true)
+    {
+        $productId = null;
+        if ($item instanceof Mage_Catalog_Model_Product) {
+            $productId = $item->getEntityId();
+        }
+        if ($item instanceof Mage_Wishlist_Model_Item) {
+            $productId = $item->getProductId();
+        }
+
+        if ($productId) {
+            $params['product'] = $productId;
+            if ($addFormKey) {
+                $params[Mage_Core_Model_Url::FORM_KEY] = $this->_getSingletonModel('core/session')->getFormKey();
+            }
+            return $this->_getUrlStore($item)->getUrl('wishlist/index/add', $params);
+        }
+
+        return false;
+    }
+
+    /**
+     * Retrieve URL for removing item from wishlist with params with or without Form Key
+     *
+     * @param Mage_Catalog_Model_Product|Mage_Wishlist_Model_Item $item
+     * @param bool $addFormKey
+     * @return string
+     */
+    public function getRemoveUrlCustom($item, $addFormKey = true)
+    {
+        $params = array(
+            'item' => $item->getWishlistItemId()
+        );
+        if ($addFormKey) {
+            $params[Mage_Core_Model_Url::FORM_KEY] = $this->_getSingletonModel('core/session')->getFormKey();
+        }
+
+        return $this->_getUrl('wishlist/index/remove', $params);
+    }
+
+    /**
+     * Retrieve URL for adding item to shopping cart with or without Form Key
+     *
+     * @param string|Mage_Catalog_Model_Product|Mage_Wishlist_Model_Item $item
+     * @param bool $addFormKey
+     * @return  string
+     */
+    public function getAddToCartUrlCustom($item, $addFormKey = true)
+    {
+        $continueUrl  = $this->_getHelperInstance('core')->urlEncode(
+            $this->_getUrl('*/*/*', array(
+                '_current'      => true,
+                '_use_rewrite'  => true,
+                '_store_to_url' => true,
+            ))
+        );
+        $params = array(
+            'item' => is_string($item) ? $item : $item->getWishlistItemId(),
+            Mage_Core_Controller_Front_Action::PARAM_NAME_URL_ENCODED => $continueUrl,
+        );
+        if ($addFormKey) {
+            $params[Mage_Core_Model_Url::FORM_KEY] = $this->_getSingletonModel('core/session')->getFormKey();
+        }
+        return $this->_getUrlStore($item)->getUrl('wishlist/index/cart', $params);
+    }
 }
diff --git app/code/core/Mage/XmlConnect/Helper/Translate.php app/code/core/Mage/XmlConnect/Helper/Translate.php
index 1889c2c1887..7b9a4ceaded 100644
--- app/code/core/Mage/XmlConnect/Helper/Translate.php
+++ app/code/core/Mage/XmlConnect/Helper/Translate.php
@@ -328,7 +328,8 @@ class Mage_XmlConnect_Helper_Translate extends Mage_Core_Helper_Abstract
             'OtherAmount' => $this->__('Other amount'),
             'OutOfStock' => $this->__('Out of Stock'),
             'ParsingError' => $this->__('Error while reading remote data'),
-            'PasswordLength' => $this->__('The minimum password length is 6'),
+            'PasswordLength' => $this->__('The minimum password length is ')
+                . Mage::getModel('customer/customer')->getMinPasswordLength(),
             'PayPalCheckout' => $this->__('PayPal Checkout'),
             'PayPalText' => $this->__('PayPal'),
             'PaymentBridgeServiceErrorMessage' => $this->__('Unknown Payment Bridge Error'),
diff --git app/design/adminhtml/default/default/template/resetforgottenpassword.phtml app/design/adminhtml/default/default/template/resetforgottenpassword.phtml
index 0af4443a759..da93bb0ca4a 100644
--- app/design/adminhtml/default/default/template/resetforgottenpassword.phtml
+++ app/design/adminhtml/default/default/template/resetforgottenpassword.phtml
@@ -50,12 +50,21 @@
                         <div id="messages">
                             <?php echo $this->getMessagesBlock()->getGroupedHtml(); ?>
                         </div>
-                        <div class="input-box f-left">
+                        <div class="input-box f-left half">
                             <label for="password"><em class="required">*</em> <?php echo $this->__('New Password'); ?></label>
                             <br />
                             <!-- This is a dummy hidden field to trick firefox from auto filling the password -->
                             <input type="password" class="input-text no-display" name="dummy" id="dummy" />
-                            <input type="password" class="input-text required-entry validate-admin-password" name="password" id="password" autocomplete="new-password"/>
+                            <input type="password"
+                                   class="input-text required-entry validate-admin-password min-admin-pass-length-<?php echo $minAdminPasswordLength; ?>"
+                                   name="password"
+                                   id="password"
+                                   autocomplete="new-password"/>
+                            <p class="note">
+                                <span>
+                                    <?php echo Mage::helper('adminhtml')->__('Password must be at least of %d characters.', $minAdminPasswordLength); ?>
+                                </span>
+                            </p>
                         </div>
                         <div class="input-box f-right">
                             <label for="confirmation"><em class="required">*</em> <?php echo $this->__('Confirm New Password'); ?></label>
diff --git app/design/frontend/base/default/template/bundle/catalog/product/view/option_tierprices.phtml app/design/frontend/base/default/template/bundle/catalog/product/view/option_tierprices.phtml
index 6e76495a11f..163c9ba839b 100644
--- app/design/frontend/base/default/template/bundle/catalog/product/view/option_tierprices.phtml
+++ app/design/frontend/base/default/template/bundle/catalog/product/view/option_tierprices.phtml
@@ -195,9 +195,9 @@ if (Mage::helper('weee')->typeOfDisplay($_product, array(1,2,4))) {
             <a href="#" id="<?php echo($popupId);?>"><?php echo $this->__('Click for price'); ?></a>
             <script type="text/javascript">
             <?php
-                    $addToCartUrl = $this->getProduct()->isSalable()
-                        ? $this->getAddToCartUrl($_product, array('qty' => $_price['price_qty']))
-                        : '';
+                $addToCartUrl = $this->getProduct()->isSalable()
+                    ? $this->getAddToCartUrlCustom($_product, array('qty' => $_price['price_qty']), false)
+                    : '';
             ?>
             <?php if (!$this->getInGrouped()): ?>
                 var newLink = {
diff --git app/design/frontend/base/default/template/catalog/product/list.phtml app/design/frontend/base/default/template/catalog/product/list.phtml
index 7fbb4c31e3e..f2b15d45411 100644
--- app/design/frontend/base/default/template/catalog/product/list.phtml
+++ app/design/frontend/base/default/template/catalog/product/list.phtml
@@ -34,6 +34,7 @@
 <?php
     $_productCollection=$this->getLoadedProductCollection();
     $_helper = $this->helper('catalog/output');
+    $_params = $this->escapeHtml(json_encode(array('form_key' => $this->getFormKey())));
 ?>
 <?php if(!$_productCollection->count()): ?>
 <p class="note-msg"><?php echo $this->__('There are no products matching the selection.') ?></p>
@@ -68,10 +69,26 @@
                     </div>
                     <ul class="add-to-links">
                         <?php if ($this->helper('wishlist')->isAllow()) : ?>
-                            <li><a href="<?php echo $this->helper('wishlist')->getAddUrl($_product) ?>" class="link-wishlist"><?php echo $this->__('Add to Wishlist') ?></a></li>
+                            <?php $_wishlistUrl = $this->helper('wishlist')->getAddUrlWithCustomParams($_product, array(), false); ?>
+                            <li>
+                                <a href="#"
+                                   data-url="<?php echo $_wishlistUrl ?>"
+                                   data-params="<?php echo $_params ?>"
+                                   class="link-wishlist"
+                                   onclick="customFormSubmit('<?php echo $_wishlistUrl ?>', '<?php echo $_params ?>', 'post')">
+                                    <?php echo $this->__('Add to Wishlist') ?>
+                                </a>
+                            </li>
                         <?php endif; ?>
-                        <?php if($_compareUrl=$this->getAddToCompareUrl($_product)): ?>
-                            <li><span class="separator">|</span> <a href="<?php echo $_compareUrl ?>" class="link-compare"><?php echo $this->__('Add to Compare') ?></a></li>
+                        <?php if ($_compareUrl = $this->getAddToCompareUrlCustom($_product, false)) : ?>
+                            <li>
+                                <span class="separator">|</span>
+                                <a href="#"
+                                   class="link-compare"
+                                   onclick="customFormSubmit('<?php echo $_compareUrl ?>', '<?php echo $_params ?>', 'post')">
+                                    <?php echo $this->__('Add to Compare') ?>
+                                </a>
+                            </li>
                         <?php endif; ?>
                     </ul>
                 </div>
@@ -106,10 +123,26 @@
                     <?php endif; ?>
                     <ul class="add-to-links">
                         <?php if ($this->helper('wishlist')->isAllow()) : ?>
-                            <li><a href="<?php echo $this->helper('wishlist')->getAddUrl($_product) ?>" class="link-wishlist"><?php echo $this->__('Add to Wishlist') ?></a></li>
+                            <?php $_wishlistUrl = $this->helper('wishlist')->getAddUrlWithCustomParams($_product, array(), false); ?>
+                            <li>
+                                <a href="#"
+                                   data-url="<?php echo $_wishlistUrl ?>"
+                                   data-params="<?php echo $_params ?>"
+                                   class="link-wishlist"
+                                   onclick="customFormSubmit('<?php echo $_wishlistUrl ?>', '<?php echo $_params ?>', 'post')">
+                                    <?php echo $this->__('Add to Wishlist') ?>
+                                </a>
+                            </li>
                         <?php endif; ?>
-                        <?php if($_compareUrl=$this->getAddToCompareUrl($_product)): ?>
-                            <li><span class="separator">|</span> <a href="<?php echo $_compareUrl ?>" class="link-compare"><?php echo $this->__('Add to Compare') ?></a></li>
+                        <?php if ($_compareUrl = $this->getAddToCompareUrlCustom($_product, false)) : ?>
+                            <li>
+                                <span class="separator">|</span>
+                                <a href="#"
+                                   class="link-compare"
+                                   onclick="customFormSubmit('<?php echo $_compareUrl ?>', '<?php echo $_params ?>', 'post')">
+                                    <?php echo $this->__('Add to Compare') ?>
+                                </a>
+                            </li>
                         <?php endif; ?>
                     </ul>
                 </div>
diff --git app/design/frontend/base/default/template/catalog/product/new.phtml app/design/frontend/base/default/template/catalog/product/new.phtml
index 0bb92538143..dc8e934eb7f 100644
--- app/design/frontend/base/default/template/catalog/product/new.phtml
+++ app/design/frontend/base/default/template/catalog/product/new.phtml
@@ -27,6 +27,7 @@
 <?php if (($_products = $this->getProductCollection()) && $_products->getSize()): ?>
 <h2 class="subtitle"><?php echo $this->__('New Products') ?></h2>
 <?php $_columnCount = $this->getColumnCount(); ?>
+<?php $_params = $this->escapeHtml(json_encode(array('form_key' => $this->getFormKey()))); ?>
     <?php $i=0; foreach ($_products->getItems() as $_product): ?>
         <?php if ($i++%$_columnCount==0): ?>
         <ul class="products-grid">
@@ -38,16 +39,40 @@
                 <?php echo $this->getPriceHtml($_product, true, '-new') ?>
                 <div class="actions">
                     <?php if($_product->isSaleable()): ?>
-                        <button type="button" title="<?php echo $this->__('Add to Cart') ?>" class="button btn-cart" onclick="setLocation('<?php echo $this->getAddToCartUrl($_product) ?>')"><span><span><?php echo $this->__('Add to Cart') ?></span></span></button>
+                        <button type="button"
+                                title="<?php echo Mage::helper('core')->quoteEscape($this->__('Add to Cart')) ?>"
+                                class="button btn-cart"
+                                onclick="customFormSubmit(
+                                        '<?php echo $this->getAddToCartUrlCustom($_product, array(), false) ?>',
+                                        '<?php echo $_params ?>',
+                                        'post')">
+                            <span><span><?php echo $this->__('Add to Cart') ?></span></span>
+                        </button>
                     <?php else: ?>
                         <p class="availability out-of-stock"><span><?php echo $this->__('Out of stock') ?></span></p>
                     <?php endif; ?>
                     <ul class="add-to-links">
                         <?php if ($this->helper('wishlist')->isAllow()) : ?>
-                            <li><a href="<?php echo $this->getAddToWishlistUrl($_product) ?>" class="link-wishlist"><?php echo $this->__('Add to Wishlist') ?></a></li>
+                            <?php $_wishlistUrl = $this->getAddToWishlistUrlCustom($_product, false); ?>
+                            <li>
+                                <a href="#"
+                                   data-url="<?php echo $_wishlistUrl ?>"
+                                   data-params="<?php echo $_params ?>"
+                                   class="link-wishlist"
+                                   onclick="customFormSubmit('<?php echo $_wishlistUrl ?>', '<?php echo $_params ?>', 'post')">
+                                    <?php echo $this->__('Add to Wishlist') ?>
+                                </a>
+                            </li>
                         <?php endif; ?>
-                        <?php if ($_compareUrl = $this->getAddToCompareUrl($_product)): ?>
-                            <li><span class="separator">|</span> <a href="<?php echo $_compareUrl ?>" class="link-compare"><?php echo $this->__('Add to Compare') ?></a></li>
+                        <?php if ($_compareUrl = $this->getAddToCompareUrlCustom($_product, false)) : ?>
+                            <li>
+                                <span class="separator">|</span>
+                                <a href="#"
+                                   class="link-compare"
+                                   onclick="customFormSubmit('<?php echo $_compareUrl ?>', '<?php echo $_params ?>', 'post')">
+                                    <?php echo $this->__('Add to Compare') ?>
+                                </a>
+                            </li>
                         <?php endif; ?>
                     </ul>
                 </div>
diff --git app/design/frontend/base/default/template/catalog/product/price_msrp.phtml app/design/frontend/base/default/template/catalog/product/price_msrp.phtml
index 01bc523fb91..3cecf5de29f 100644
--- app/design/frontend/base/default/template/catalog/product/price_msrp.phtml
+++ app/design/frontend/base/default/template/catalog/product/price_msrp.phtml
@@ -52,7 +52,7 @@
                         "<?php echo $_product->getName() ?>",
                         <?php echo $this->getRealPriceJs($_product) ?>,
                         '<?php echo $_msrpPrice ?>',
-                        "<?php echo $_product->isSalable() ? $_product->getAddToCartUrl() : '' ?>"
+                        "<?php echo $_product->isSalable() ? $this->getAddToCartUrlCustom($_product, array(), false) : '' ?>"
                 );
                 newLink.product_id = '<?php echo $_product->getId() ?>';
             <?php else: ?>
diff --git app/design/frontend/base/default/template/catalog/product/price_msrp_item.phtml app/design/frontend/base/default/template/catalog/product/price_msrp_item.phtml
index 549a885429d..0a1fcfc40fe 100644
--- app/design/frontend/base/default/template/catalog/product/price_msrp_item.phtml
+++ app/design/frontend/base/default/template/catalog/product/price_msrp_item.phtml
@@ -87,7 +87,7 @@
                     "<?php echo $_product->getName() ?>",
                     $("<?php echo $priceElementId ?>"),
                     '<?php echo $_msrpPrice ?>',
-                    "<?php echo $_product->isSalable() ? $_product->getAddToCartUrl() : '' ?>"
+                    "<?php echo $_product->isSalable() ? $this->getAddToCartUrlCustom($_product, array(), false) : '' ?>"
                 );
             </script>
         <?php else: ?>
diff --git app/design/frontend/base/default/template/catalog/product/price_msrp_noform.phtml app/design/frontend/base/default/template/catalog/product/price_msrp_noform.phtml
index 65b6a5b6c1c..87d9f1a188d 100644
--- app/design/frontend/base/default/template/catalog/product/price_msrp_noform.phtml
+++ app/design/frontend/base/default/template/catalog/product/price_msrp_noform.phtml
@@ -48,7 +48,7 @@
         <script type="text/javascript">
             <?php if ($this->helper('catalog')->isShowPriceOnGesture($_product)): ?>
                 var productLink = {
-                    url: "<?php echo $_product->isSalable() ? $_product->getAddToCartUrl() : '' ?>",
+                    url: "<?php echo $_product->isSalable() ? $this->getAddToCartUrlCustom($_product, array(), false) : '' ?>",
                     notUseForm: true
                 };
                 var newLink = Catalog.Map.addHelpLink(
diff --git app/design/frontend/base/default/template/catalog/product/view/tierprices.phtml app/design/frontend/base/default/template/catalog/product/view/tierprices.phtml
index abb994a1fe5..77aaf9d7e60 100644
--- app/design/frontend/base/default/template/catalog/product/view/tierprices.phtml
+++ app/design/frontend/base/default/template/catalog/product/view/tierprices.phtml
@@ -196,7 +196,7 @@ if (Mage::helper('weee')->typeOfDisplay($_product, array(1,2,4))) {
             <script type="text/javascript">
             <?php
                     $addToCartUrl = $this->getProduct()->isSalable()
-                        ? $this->getAddToCartUrl($_product, array('qty' => $_price['price_qty']))
+                        ? $this->getAddToCartUrlCustom($_product, array('qty' => $_price['price_qty']), false)
                         : '';
             ?>
             <?php if (!$this->getInGrouped()): ?>
diff --git app/design/frontend/base/default/template/reports/home_product_compared.phtml app/design/frontend/base/default/template/reports/home_product_compared.phtml
index edf6294770b..84d7299a133 100644
--- app/design/frontend/base/default/template/reports/home_product_compared.phtml
+++ app/design/frontend/base/default/template/reports/home_product_compared.phtml
@@ -28,6 +28,7 @@
 <?php if ($_products = $this->getRecentlyComparedProducts()): ?>
 <h2 class="subtitle"><?php echo $this->__('Your Recently Compared') ?></h2>
 <?php $_columnCount = $this->getColumnCount(); ?>
+<?php $_params = $this->escapeHtml(json_encode(array('form_key' => $this->getFormKey()))); ?>
     <?php $i=0; foreach ($_products as $_product): ?>
         <?php if ($i++%$_columnCount==0): ?>
         <ul class="products-grid">
@@ -39,16 +40,39 @@
                 <?php echo $this->getPriceHtml($_product, true, '-home-compared') ?>
                 <div class="actions">
                     <?php if($_product->isSaleable()): ?>
-                        <button type="button" title="<?php echo $this->__('Add to Cart') ?>" class="button btn-cart" onclick="setLocation('<?php echo $this->getAddToCartUrl($_product) ?>')"><span><span><?php echo $this->__('Add to Cart') ?></span></span></button>
+                        <button type="button"
+                                title="<?php echo Mage::helper('core')->quoteEscape($this->__('Add to Cart')) ?>"
+                                class="button btn-cart"
+                                onclick="customFormSubmit('<?php echo $this->getAddToCartUrlCustom($_product, array(), false) ?>',
+                                        '<?php echo $_params ?>',
+                                        'post')">
+                            <span><span><?php echo $this->__('Add to Cart') ?></span></span>
+                        </button>
                     <?php else: ?>
                         <p class="availability out-of-stock"><span><?php echo $this->__('Out of stock') ?></span></p>
                     <?php endif; ?>
                     <ul class="add-to-links">
                         <?php if ($this->helper('wishlist')->isAllow()) : ?>
-                            <li><a href="<?php echo $this->getAddToWishlistUrl($_product) ?>" class="link-wishlist"><?php echo $this->__('Add to Wishlist') ?></a></li>
+                            <?php $_wishlistUrl = $this->getAddToWishlistUrlCustom($_product, false); ?>
+                            <li>
+                                <a href="#"
+                                   data-url="<?php echo $_wishlistUrl ?>"
+                                   data-params="<?php echo $_params ?>"
+                                   class="link-wishlist"
+                                   onclick="customFormSubmit('<?php echo $_wishlistUrl ?>', '<?php echo $_params ?>', 'post')">
+                                    <?php echo $this->__('Add to Wishlist') ?>
+                                </a>
+                            </li>
                         <?php endif; ?>
-                        <?php if ($_compareUrl = $this->getAddToCompareUrl($_product)): ?>
-                            <li><span class="separator">|</span> <a href="<?php echo $_compareUrl ?>" class="link-compare"><?php echo $this->__('Add to Compare') ?></a></li>
+                        <?php if ($_compareUrl = $this->getAddToCompareUrlCustom($_product, false)) : ?>
+                            <li>
+                                <span class="separator">|</span>
+                                <a href="#"
+                                   class="link-compare"
+                                   onclick="customFormSubmit('<?php echo $_compareUrl ?>', '<?php echo $_params ?>', 'post')">
+                                    <?php echo $this->__('Add to Compare') ?>
+                                </a>
+                            </li>
                         <?php endif; ?>
                     </ul>
                 </div>
diff --git app/design/frontend/base/default/template/reports/home_product_viewed.phtml app/design/frontend/base/default/template/reports/home_product_viewed.phtml
index dfc8440bebf..d59f6a751fe 100644
--- app/design/frontend/base/default/template/reports/home_product_viewed.phtml
+++ app/design/frontend/base/default/template/reports/home_product_viewed.phtml
@@ -33,6 +33,7 @@
 <?php if ($_products = $this->getRecentlyViewedProducts()): ?>
 <h2 class="subtitle"><?php echo $this->__('Your Recently Viewed') ?></h2>
 <?php $_columnCount = $this->getColumnCount(); ?>
+<?php $_params = $this->escapeHtml(json_encode(array('form_key' => $this->getFormKey()))); ?>
     <?php $i=0; foreach ($_products as $_product): ?>
         <?php if ($i++%$_columnCount==0): ?>
         <ul class="products-grid">
@@ -44,16 +45,39 @@
                 <?php echo $this->getPriceHtml($_product, true, '-home-viewed') ?>
                 <div class="actions">
                     <?php if($_product->isSaleable()): ?>
-                        <button type="button" title="<?php echo $this->__('Add to Cart') ?>" class="button btn-cart" onclick="setLocation('<?php echo $this->getAddToCartUrl($_product) ?>')"><span><span><?php echo $this->__('Add to Cart') ?></span></span></button>
+                        <button type="button"
+                                title="<?php echo Mage::helper('core')->quoteEscape($this->__('Add to Cart')) ?>"
+                                class="button btn-cart"
+                                onclick="customFormSubmit(
+                                        '<?php echo $this->getAddToCartUrlCustom($_product, array(), false) ?>',
+                                        '<?php echo $_params ?>',
+                                        'post')">
+                            <span><span><?php echo $this->__('Add to Cart') ?></span></span>
+                        </button>
                     <?php else: ?>
                         <p class="availability out-of-stock"><span><?php echo $this->__('Out of stock') ?></span></p>
                     <?php endif; ?>
                     <ul class="add-to-links">
                         <?php if ($this->helper('wishlist')->isAllow()) : ?>
-                            <li><a href="<?php echo $this->getAddToWishlistUrl($_product) ?>" class="link-wishlist"><?php echo $this->__('Add to Wishlist') ?></a></li>
-                        <?php endif; ?>
-                        <?php if ($_compareUrl = $this->getAddToCompareUrl($_product)): ?>
-                            <li><span class="separator">|</span> <a href="<?php echo $_compareUrl ?>" class="link-compare"><?php echo $this->__('Add to Compare') ?></a></li>
+                            <?php $_wishlistUrl = $this->getAddToWishlistUrlCustom($_product, false); ?>
+                            <li>
+                                <a href="#"
+                                   data-url="<?php echo $_wishlistUrl ?>"
+                                   data-params="<?php echo $_params ?>"
+                                   class="link-wishlist"
+                                   onclick="customFormSubmit('<?php echo $_wishlistUrl ?>', '<?php echo $_params ?>', 'post')">
+                                    <?php echo $this->__('Add to Wishlist') ?>
+                                </a>
+                            </li>                        <?php endif; ?>
+                        <?php if ($_compareUrl = $this->getAddToCompareUrlCustom($_product, false)) : ?>
+                            <li>
+                                <span class="separator">|</span>
+                                <a href="#"
+                                   class="link-compare"
+                                   onclick="customFormSubmit('<?php echo $_compareUrl ?>', '<?php echo $_params ?>', 'post')">
+                                    <?php echo $this->__('Add to Compare') ?>
+                                </a>
+                            </li>
                         <?php endif; ?>
                     </ul>
                 </div>
diff --git app/design/frontend/base/default/template/wishlist/item/column/remove.phtml app/design/frontend/base/default/template/wishlist/item/column/remove.phtml
index cd590069e53..67478df61fd 100644
--- app/design/frontend/base/default/template/wishlist/item/column/remove.phtml
+++ app/design/frontend/base/default/template/wishlist/item/column/remove.phtml
@@ -25,5 +25,15 @@
  */
 
 ?>
-<a href="<?php echo $this->getItemRemoveUrl($this->getItem()); ?>" onclick="return confirmRemoveWishlistItem();" title="<?php echo $this->__('Remove Item') ?>"
-    class="btn-remove btn-remove2"><?php echo $this->__('Remove item');?></a>
+<a href="#"
+   class="btn-remove btn-remove2"
+   title="<?php echo Mage::helper('core')->quoteEscape($this->__('Remove Item')) ?>"
+   onclick="if (confirmRemoveWishlistItem()) {
+                customFormSubmit(
+                    '<?php echo $this->getItemRemoveUrlCustom($this->getItem(), false) ?>',
+                    '<?php echo $this->escapeHtml(json_encode(array('form_key' => $this->getFormKey()))) ?>',
+                    'post'
+                )
+            }">
+    <?php echo $this->__('Remove item') ?>
+</a>
diff --git app/design/frontend/base/default/template/wishlist/item/configure/addto.phtml app/design/frontend/base/default/template/wishlist/item/configure/addto.phtml
index dcb152f8552..dd40b8dcb31 100644
--- app/design/frontend/base/default/template/wishlist/item/configure/addto.phtml
+++ app/design/frontend/base/default/template/wishlist/item/configure/addto.phtml
@@ -32,8 +32,18 @@
     <li><a href="<?php echo $_wishlistSubmitUrl ?>" onclick="productAddToCartForm.submitLight(this, this.href); return false;" class="link-compare"><?php echo $this->__('Update Wishlist') ?></a></li>
 <?php endif; ?>
 <?php $_product = $this->getProduct(); ?>
-<?php $_compareUrl = $this->helper('catalog/product_compare')->getAddUrl($_product); ?>
+<?php $_compareUrl = $this->helper('catalog/product_compare')->getAddUrlCustom($_product, false); ?>
 <?php if ($_compareUrl) : ?>
-    <li><span class="separator">|</span> <a href="<?php echo $_compareUrl ?>" class="link-compare"><?php echo $this->__('Add to Compare') ?></a></li>
+    <li>
+        <span class="separator">|</span>
+        <a href="#"
+           class="link-compare"
+           onclick="customFormSubmit(
+                   '<?php echo $_compareUrl ?>',
+                   '<?php echo $this->escapeHtml(json_encode(array('form_key' => $this->getFormKey()))) ?>',
+                   'post')">
+            <?php echo $this->__('Add to Compare') ?>
+        </a>
+    </li>
 <?php endif; ?>
 </ul>
diff --git app/design/frontend/base/default/template/wishlist/render/item/price_msrp_item.phtml app/design/frontend/base/default/template/wishlist/render/item/price_msrp_item.phtml
index 756a9e0009e..6e98745026f 100644
--- app/design/frontend/base/default/template/wishlist/render/item/price_msrp_item.phtml
+++ app/design/frontend/base/default/template/wishlist/render/item/price_msrp_item.phtml
@@ -85,7 +85,7 @@
                     "<?php echo $_product->getName() ?>",
                     $("<?php echo $priceElementId ?>"),
                     '<?php echo $_msrpPrice ?>',
-                    "<?php echo $_product->isSalable() ? $_product->getAddToCartUrl() : '' ?>"
+                    "<?php echo $_product->isSalable() ? $this->getAddToCartUrlCustom($_product, array(), false) : '' ?>"
                 );
             </script>
         <?php else: ?>
diff --git app/design/install/default/default/template/install/create_admin.phtml app/design/install/default/default/template/install/create_admin.phtml
index fb78ac7bd3b..c6ef6f5639d 100644
--- app/design/install/default/default/template/install/create_admin.phtml
+++ app/design/install/default/default/template/install/create_admin.phtml
@@ -68,7 +68,18 @@
                 <label for="password"><?php echo $this->__('Password') ?> <span class="required">*</span></label><br/>
                 <!-- This is a dummy hidden field to trick firefox from auto filling the password -->
                 <input type="password" class="input-text" name="dummy" id="dummy" style="display: none;"/>
-                <input type="password" name="admin[new_password]" id="password" title="<?php echo Mage::helper('core')->quoteEscape($this->__('Password')) ?>" class="required-entry validate-admin-password input-text" autocomplete="new-password"/>
+                <?php $minAdminPasswordLength = $this->getMinAdminPasswordLength(); ?>
+                <input type="password"
+                       name="admin[new_password]"
+                       id="password"
+                       title="<?php echo Mage::helper('core')->quoteEscape($this->__('Password')) ?>"
+                       class="required-entry validate-admin-password input-text min-admin-pass-length-<?php echo $minAdminPasswordLength ?>"
+                       autocomplete="new-password"/>
+                <p class="note">
+                    <span>
+                        <?php echo Mage::helper('adminhtml')->__('Password must be at least of %d characters.', $minAdminPasswordLength) ?>
+                    </span>
+                </p>
             </div>
             <div class="input-box">
                 <label for="confirmation"><?php echo $this->__('Confirm Password') ?> <span
diff --git app/locale/en_US/Mage_Adminhtml.csv app/locale/en_US/Mage_Adminhtml.csv
index 51cba8148f9..67362f77f3c 100644
--- app/locale/en_US/Mage_Adminhtml.csv
+++ app/locale/en_US/Mage_Adminhtml.csv
@@ -413,6 +413,8 @@
 "Helper attributes should not be used in custom layout updates.","Helper attributes should not be used in custom layout updates."
 "Helper for options rendering doesn't implement required interface.","Helper for options rendering doesn't implement required interface."
 "Home","Home"
+"Key %s does not contain scalar value","Key %s does not contain scalar value"
+"Key %s does not exist in array","Key %s does not exist in array"
 "ID","ID"
 "ID Path","ID Path"
 "IP Address","IP Address"
@@ -1152,6 +1154,7 @@
 "Wrong account specified.","Wrong account specified."
 "Wrong billing agreement ID specified.","Wrong billing agreement ID specified."
 "Wrong column format.","Wrong column format."
+"Wrong field specified.","Wrong field specified."
 "Wrong newsletter template.","Wrong newsletter template."
 "Wrong quote item.","Wrong quote item."
 "Wrong tab configuration.","Wrong tab configuration."
diff --git app/locale/en_US/Mage_Api.csv app/locale/en_US/Mage_Api.csv
index e5638ade110..7594c2c7526 100644
--- app/locale/en_US/Mage_Api.csv
+++ app/locale/en_US/Mage_Api.csv
@@ -1,18 +1,26 @@
+"A user with the same user name or email already exists.","A user with the same user name or email already exists."
 "Access denied.","Access denied."
+"Api Key confirmation must be same as Api Key.","Api Key confirmation must be same as Api Key."
+"Api Key must be at least of %d characters.","Api Key must be at least of %d characters."
+"Api Key must include both numeric and alphabetic characters.","Api Key must include both numeric and alphabetic characters."
 "Can not find webservice adapter.","Can not find webservice adapter."
 "Client Session Timeout (sec.)","Client Session Timeout (sec.)"
 "Default Response Charset","Default Response Charset"
 "Email","Email"
 "Enable WSDL Cache","Enable WSDL Cache"
+"First Name is required field.","First Name is required field."
 "General Settings","General Settings"
 "Invalid webservice adapter specified.","Invalid webservice adapter specified."
 "Invalid webservice handler specified.","Invalid webservice handler specified."
+"Last Name is required field.","Last Name is required field."
 "Magento Core API","Magento Core API"
 "Magento Core API Section","Magento Core API Section"
+"Please enter a valid email.","Please enter a valid email."
 "SOAP/XML-RPC - Roles","SOAP/XML-RPC - Roles"
 "SOAP/XML-RPC - Users","SOAP/XML-RPC - Users"
 "Unable to login.","Unable to login."
 "User Name","User Name"
+"User Name is required field.","User Name is required field."
 "WS-I Compliance","WS-I Compliance"
 "Web Services","Web Services"
 "Your account has been deactivated.","Your account has been deactivated."
diff --git app/locale/en_US/Mage_Core.csv app/locale/en_US/Mage_Core.csv
index c17422e3343..45b7017e2dd 100644
--- app/locale/en_US/Mage_Core.csv
+++ app/locale/en_US/Mage_Core.csv
@@ -52,6 +52,7 @@
 "Can\'t retrieve entity config: %s","Can\'t retrieve entity config: %s"
 "Cancel","Cancel"
 "Cannot complete this operation from non-admin area.","Cannot complete this operation from non-admin area."
+"Disallowed block name for frontend.","Disallowed block name for frontend."
 "Disallowed template variable method.","Disallowed template variable method."
 "Card type does not match credit card number.","Card type does not match credit card number."
 "Code","Code"
@@ -142,9 +143,11 @@
 "General Settings","General Settings"
 "Get info about current Magento installation","Get info about current Magento installation"
 "Global","Global"
+"HTML filtration has failed.","HTML filtration has failed."
 "HTML Head","HTML Head"
 "HTML tags are not allowed","HTML tags are not allowed"
 "Header","Header"
+"Helper attributes should not be used in custom layout updates.","Helper attributes should not be used in custom layout updates."
 "Host","Host"
 "How many links to display at once.","How many links to display at once."
 "ID Path for Specified Store","ID Path for Specified Store"
@@ -161,6 +164,7 @@
 "Invalid layout update handle","Invalid layout update handle"
 "Invalid messages storage ""%s"" for layout messages initialization","Invalid messages storage ""%s"" for layout messages initialization"
 "Invalid stream.","Invalid stream."
+"Invalid template path used in layout update.","Invalid template path used in layout update."
 "Invalid query","Invalid query"
 "Invalid transactional email code: %s","Invalid transactional email code: %s"
 "Invalid website\'s configuration path: %s","Invalid website\'s configuration path: %s"
@@ -192,6 +196,7 @@
 "Module ""%1$s"" cannot depend on ""%2$s"".","Module ""%1$s"" cannot depend on ""%2$s""."
 "Module ""%1$s"" requires module ""%2$s"".","Module ""%1$s"" requires module ""%2$s""."
 "Name","Name"
+"File name is too long. Maximum length is %s.","File name is too long. Maximum length is %s."
 "New Design Change","New Design Change"
 "New Store","New Store"
 "New Store View","New Store View"
@@ -237,6 +242,8 @@
 "Please enter a valid zip code.","Please enter a valid zip code."
 "Please enter a valid zip code. For example 90602 or 90602-1234.","Please enter a valid zip code. For example 90602 or 90602-1234."
 "Please enter issue number or start date for switch/solo card type.","Please enter issue number or start date for switch/solo card type."
+"Please enter more characters or clean leading or trailing spaces.","Please enter more characters or clean leading or trailing spaces."
+"Please enter more characters. Password should contain both numeric and alphabetic characters.","Please enter more characters. Password should contain both numeric and alphabetic characters."
 "Please input a valid CSS-length. For example 100px or 77pt or 20em or .5ex or 50%.","Please input a valid CSS-length. For example 100px or 77pt or 20em or .5ex or 50%."
 "Please make sure your passwords match.","Please make sure your passwords match."
 "Please select State/Province.","Please select State/Province."
@@ -389,6 +396,8 @@
 "Wrong file info format","Wrong file info format"
 "Wrong number of arguments for %s","Wrong number of arguments for %s"
 "Wrong old style column type definition: {$definition}.","Wrong old style column type definition: {$definition}."
+"XML data is invalid.","XML data is invalid."
+"XML object is not instance of ""Varien_Simplexml_Element"".","XML object is not instance of ""Varien_Simplexml_Element""."
 "Yes","Yes"
 "You will have to log in after you save your custom admin path.","You will have to log in after you save your custom admin path."
 "Your design change for the specified store intersects with another one, please specify another date range.","Your design change for the specified store intersects with another one, please specify another date range."
diff --git app/locale/en_US/Mage_Customer.csv app/locale/en_US/Mage_Customer.csv
index 6b9bc7b72b6..913ba3a036a 100644
--- app/locale/en_US/Mage_Customer.csv
+++ app/locale/en_US/Mage_Customer.csv
@@ -205,6 +205,8 @@
 "Manage Addresses","Manage Addresses"
 "Manage Customers","Manage Customers"
 "Maximum length must be less then %s symbols","Maximum length must be less then %s symbols"
+"Minimum admin password length","Minimum admin password length"
+"Minimum password length","Minimum password length"
 "Missing email, skipping the record, line: %s","Missing email, skipping the record, line: %s"
 "Missing email, skipping the record.","Missing email, skipping the record."
 "Missing first name, skipping the record, line: %s","Missing first name, skipping the record, line: %s"
@@ -267,6 +269,7 @@
 "Per Website","Per Website"
 "Personal Information","Personal Information"
 "Please enter a number 1 or greater in this field.","Please enter a number 1 or greater in this field."
+"Please enter a number 7 or greater in this field.","Please enter a number 7 or greater in this field."
 "Please enter a valid date between %s and %s at %s.","Please enter a valid date between %s and %s at %s."
 "Please enter a valid date equal to or greater than %s at %s.","Please enter a valid date equal to or greater than %s at %s."
 "Please enter a valid date less than or equal to %s at %s.","Please enter a valid date less than or equal to %s at %s."
@@ -392,6 +395,7 @@
 "The minimum password length is %s","The minimum password length is %s"
 "The password cannot be empty.","The password cannot be empty."
 "The password must have at least 6 characters. Leading or trailing spaces will be ignored.","The password must have at least 6 characters. Leading or trailing spaces will be ignored."
+"The password must have at least %d characters. Leading or trailing spaces will be ignored.","The password must have at least %d characters. Leading or trailing spaces will be ignored."
 "The suffix that goes after name (Jr., Sr., etc.)","The suffix that goes after name (Jr., Sr., etc.)"
 "The title that goes before name (Mr., Mrs., etc.)","The title that goes before name (Mr., Mrs., etc.)"
 "There are no items in customer's wishlist at the moment","There are no items in customer's wishlist at the moment"
diff --git app/locale/en_US/Mage_Dataflow.csv app/locale/en_US/Mage_Dataflow.csv
index 50bac5fd18e..3197c6ead37 100644
--- app/locale/en_US/Mage_Dataflow.csv
+++ app/locale/en_US/Mage_Dataflow.csv
@@ -1,5 +1,6 @@
 "<a href=""%s"" target=""_blank"">Link</a>","<a href=""%s"" target=""_blank"">Link</a>"
 "Actions XML is not valid.","Actions XML is not valid."
+"Upload failed. Can not find required columns: %s in file %s.", "Upload failed. Can not find required columns: %s in file %s."
 "An error occurred while opening file: ""%s"".","An error occurred while opening file: ""%s""."
 "Could not load file: ""%s"".","Could not load file: ""%s""."
 "Could not save file: %s.","Could not save file: %s."
@@ -12,6 +13,7 @@
 "Error in field mapping: field list for mapping is not defined.","Error in field mapping: field list for mapping is not defined."
 "File ""%s"" does not exist.","File ""%s"" does not exist."
 "Found %d rows.","Found %d rows."
+"Invalid node.", "Invalid node."
 "Less than a minute","Less than a minute"
 "Loaded successfully: ""%s"".","Loaded successfully: ""%s""."
 "Memory Used: %s","Memory Used: %s"
@@ -26,6 +28,7 @@
 "Starting %s :: %s","Starting %s :: %s"
 "The destination folder ""%s"" does not exist or there is no access to create it.","The destination folder ""%s"" does not exist or there is no access to create it."
 "Total records: %s","Total records: %s"
+"Upload failed. Wrong data format in file: %s.","Upload failed. Wrong data format in file: %s."
 "hour","hour"
 "hours","hours"
 "minute","minute"
diff --git app/locale/en_US/Mage_Eav.csv app/locale/en_US/Mage_Eav.csv
index 2b490b2bc4f..57e83b4f5df 100644
--- app/locale/en_US/Mage_Eav.csv
+++ app/locale/en_US/Mage_Eav.csv
@@ -110,6 +110,7 @@
 "Text Field","Text Field"
 "The value of attribute ""%s"" must be unique","The value of attribute ""%s"" must be unique"
 "The value of attribute ""%s"" must be unique.","The value of attribute ""%s"" must be unique."
+"The value of attribute ""%s"" contains invalid data.","The value of attribute ""%s"" contains invalid data."
 "This attribute is used in configurable products","This attribute is used in configurable products"
 "URL","URL"
 "Unique Value","Unique Value"
diff --git app/locale/en_US/Mage_XmlConnect.csv app/locale/en_US/Mage_XmlConnect.csv
index 6b515d79f68..8a055964650 100644
--- app/locale/en_US/Mage_XmlConnect.csv
+++ app/locale/en_US/Mage_XmlConnect.csv
@@ -974,6 +974,7 @@
 "The icon that appears in the Android Market.","The icon that appears in the Android Market."
 "The length of the text in the %s field is too big. Please shorten the text.","The length of the text in the %s field is too big. Please shorten the text."
 "The max length of the field ""%@"" is %d!","The max length of the field ""%@"" is %d!"
+"The minimum password length is ","The minimum password length is "
 "The minimum password length is 6","The minimum password length is 6"
 "The server responded with invalid data.","The server responded with invalid data."
 "The shortening service returned status code %d indicating a client side error.","The shortening service returned status code %d indicating a client side error."
diff --git js/mage/adminhtml/variables.js js/mage/adminhtml/variables.js
index 3f61eaa0f3f..ecce6f1438f 100644
--- js/mage/adminhtml/variables.js
+++ js/mage/adminhtml/variables.js
@@ -105,7 +105,7 @@ var Variables = {
         }
     },
     prepareVariableRow: function(varValue, varLabel) {
-        var value = (varValue).replace(/"/g, '&quot;').replace(/'/g, '\\&#39;');
+        var value = (varValue).replace(/"/g, '&quot;').replace(/\\/g, '\\\\').replace(/'/g, '\\&#39;');
         var content = '<a href="#" onclick="'+this.insertFunction+'(\''+ value +'\');return false;">' + varLabel + '</a>';
         return content;
     },
diff --git js/prototype/validation.js js/prototype/validation.js
index c9c17988033..e55a5cb7575 100644
--- js/prototype/validation.js
+++ js/prototype/validation.js
@@ -531,11 +531,18 @@ Validation.addAllThese([
     ['validate-emailSender', 'Please use only visible characters and spaces.', function (v) {
                 return Validation.get('IsEmpty').test(v) ||  /^[\S ]+$/.test(v)
                     }],
-    ['validate-password', 'Please enter 6 or more characters. Leading or trailing spaces will be ignored.', function(v) {
+    ['validate-password', 'Please enter more characters or clean leading or trailing spaces.', function(v, elm) {
                 var pass=v.strip(); /*strip leading and trailing spaces*/
-                return !(pass.length>0 && pass.length < 6);
+                var reMin = new RegExp(/^min-pass-length-[0-9]+$/);
+                var minLength = 7;
+                $w(elm.className).each(function(name, index) {
+                    if (name.match(reMin)) {
+                        minLength = name.split('-')[3];
+                    }
+                });
+                return (!(v.length > 0 && v.length < minLength) && v.length == pass.length);
             }],
-    ['validate-admin-password', 'Please enter 7 or more characters. Password should contain both numeric and alphabetic characters.', function(v) {
+    ['validate-admin-password', 'Please enter more characters. Password should contain both numeric and alphabetic characters.', function(v, elm) {
                 var pass=v.strip();
                 if (0 == pass.length) {
                     return true;
@@ -543,7 +550,14 @@ Validation.addAllThese([
                 if (!(/[a-z]/i.test(v)) || !(/[0-9]/.test(v))) {
                     return false;
                 }
-                return !(pass.length < 7);
+                var reMin = new RegExp(/^min-admin-pass-length-[0-9]+$/);
+                var minLength = 7;
+                $w(elm.className).each(function(name, index) {
+                    if (name.match(reMin)) {
+                        minLength = name.split('-')[4];
+                    }
+                });
+                return !(pass.length < minLength);
             }],
     ['validate-cpassword', 'Please make sure your passwords match.', function(v) {
                 var conf = $('confirmation') ? $('confirmation') : $$('.validate-cpassword')[0];
@@ -659,8 +673,8 @@ Validation.addAllThese([
     ['validate-state', 'Please select State/Province.', function(v) {
                 return (v!=0 || v == '');
             }],
-    ['validate-new-password', 'Please enter 6 or more characters. Leading or trailing spaces will be ignored.', function(v) {
-                if (!Validation.get('validate-password').test(v)) return false;
+    ['validate-new-password', 'Please enter more characters or clean leading or trailing spaces.', function(v, elm) {
+                if (!Validation.get('validate-password').test(v, elm)) return false;
                 if (Validation.get('IsEmpty').test(v) && v != '') return false;
                 return true;
             }],
diff --git js/tiny_mce/plugins/media/editor_plugin.js js/tiny_mce/plugins/media/editor_plugin.js
index 37b4320bd9f..46ade8594ca 100644
--- js/tiny_mce/plugins/media/editor_plugin.js
+++ js/tiny_mce/plugins/media/editor_plugin.js
@@ -1 +1 @@
-(function(){var d=tinymce.explode("id,name,width,height,style,align,class,hspace,vspace,bgcolor,type"),h=tinymce.makeMap(d.join(",")),b=tinymce.html.Node,f,a,g=tinymce.util.JSON,e;f=[["Flash","d27cdb6e-ae6d-11cf-96b8-444553540000","application/x-shockwave-flash","http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0"],["ShockWave","166b1bca-3f9c-11cf-8075-444553540000","application/x-director","http://download.macromedia.com/pub/shockwave/cabs/director/sw.cab#version=8,5,1,0"],["WindowsMedia","6bf52a52-394a-11d3-b153-00c04f79faa6,22d6f312-b0f6-11d0-94ab-0080c74c7e95,05589fa1-c356-11ce-bf01-00aa0055595a","application/x-mplayer2","http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=5,1,52,701"],["QuickTime","02bf25d5-8c17-4b23-bc80-d3488abddc6b","video/quicktime","http://www.apple.com/qtactivex/qtplugin.cab#version=6,0,2,0"],["RealMedia","cfcdaa03-8be4-11cf-b84b-0020afbbccfa","audio/x-pn-realaudio-plugin","http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0"],["Java","8ad9c840-044e-11d1-b3e9-00805f499d93","application/x-java-applet","http://java.sun.com/products/plugin/autodl/jinstall-1_5_0-windows-i586.cab#Version=1,5,0,0"],["Silverlight","dfeaf541-f3e1-4c24-acac-99c30715084a","application/x-silverlight-2"],["Iframe"],["Video"],["EmbeddedAudio"],["Audio"]];function c(m){var l,j,k;if(m&&!m.splice){j=[];for(k=0;true;k++){if(m[k]){j[k]=m[k]}else{break}}return j}return m}tinymce.create("tinymce.plugins.MediaPlugin",{init:function(n,j){var r=this,l={},m,p,q,k;function o(i){return i&&i.nodeName==="IMG"&&n.dom.hasClass(i,"mceItemMedia")}r.editor=n;r.url=j;a="";for(m=0;m<f.length;m++){k=f[m][0];q={name:k,clsids:tinymce.explode(f[m][1]||""),mimes:tinymce.explode(f[m][2]||""),codebase:f[m][3]};for(p=0;p<q.clsids.length;p++){l["clsid:"+q.clsids[p]]=q}for(p=0;p<q.mimes.length;p++){l[q.mimes[p]]=q}l["mceItem"+k]=q;l[k.toLowerCase()]=q;a+=(a?"|":"")+k}tinymce.each(n.getParam("media_types","video=mp4,m4v,ogv,webm;silverlight=xap;flash=swf,flv;shockwave=dcr;quicktime=mov,qt,mpg,mpeg;shockwave=dcr;windowsmedia=avi,wmv,wm,asf,asx,wmx,wvx;realmedia=rm,ra,ram;java=jar;audio=mp3,ogg").split(";"),function(v){var s,u,t;v=v.split(/=/);u=tinymce.explode(v[1].toLowerCase());for(s=0;s<u.length;s++){t=l[v[0].toLowerCase()];if(t){l[u[s]]=t}}});a=new RegExp("write("+a+")\\(([^)]+)\\)");r.lookup=l;n.onPreInit.add(function(){n.schema.addValidElements("object[id|style|width|height|classid|codebase|*],param[name|value],embed[id|style|width|height|type|src|*],video[*],audio[*],source[*]");n.parser.addNodeFilter("object,embed,video,audio,script,iframe",function(s){var t=s.length;while(t--){r.objectToImg(s[t])}});n.serializer.addNodeFilter("img",function(s,u,t){var v=s.length,w;while(v--){w=s[v];if((w.attr("class")||"").indexOf("mceItemMedia")!==-1){r.imgToObject(w,t)}}})});n.onInit.add(function(){if(n.theme&&n.theme.onResolveName){n.theme.onResolveName.add(function(i,s){if(s.name==="img"&&n.dom.hasClass(s.node,"mceItemMedia")){s.name="media"}})}if(n&&n.plugins.contextmenu){n.plugins.contextmenu.onContextMenu.add(function(s,t,i){if(i.nodeName==="IMG"&&i.className.indexOf("mceItemMedia")!==-1){t.add({title:"media.edit",icon:"media",cmd:"mceMedia"})}})}});n.addCommand("mceMedia",function(){var s,i;i=n.selection.getNode();if(o(i)){s=n.dom.getAttrib(i,"data-mce-json");if(s){s=g.parse(s);tinymce.each(d,function(t){var u=n.dom.getAttrib(i,t);if(u){s[t]=u}});s.type=r.getType(i.className).name.toLowerCase()}}if(!s){s={type:"flash",video:{sources:[]},params:{}}}n.windowManager.open({file:j+"/media.htm",width:430+parseInt(n.getLang("media.delta_width",0)),height:500+parseInt(n.getLang("media.delta_height",0)),inline:1},{plugin_url:j,data:s})});n.addButton("media",{title:"media.desc",cmd:"mceMedia"});n.onNodeChange.add(function(s,i,t){i.setActive("media",o(t))})},convertUrl:function(k,n){var j=this,m=j.editor,l=m.settings,o=l.url_converter,i=l.url_converter_scope||j;if(!k){return k}if(n){return m.documentBaseURI.toAbsolute(k)}return o.call(i,k,"src","object")},getInfo:function(){return{longname:"Media",author:"Moxiecode Systems AB",authorurl:"http://tinymce.moxiecode.com",infourl:"http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/media",version:tinymce.majorVersion+"."+tinymce.minorVersion}},dataToImg:function(m,k){var r=this,o=r.editor,p=o.documentBaseURI,j,q,n,l;m.params.src=r.convertUrl(m.params.src,k);q=m.video.attrs;if(q){q.src=r.convertUrl(q.src,k)}if(q){q.poster=r.convertUrl(q.poster,k)}j=c(m.video.sources);if(j){for(l=0;l<j.length;l++){j[l].src=r.convertUrl(j[l].src,k)}}n=r.editor.dom.create("img",{id:m.id,style:m.style,align:m.align,hspace:m.hspace,vspace:m.vspace,src:r.editor.theme.url+"/img/trans.gif","class":"mceItemMedia mceItem"+r.getType(m.type).name,"data-mce-json":g.serialize(m,"'")});n.width=m.width||(m.type=="audio"?"300":"320");n.height=m.height||(m.type=="audio"?"32":"240");return n},dataToHtml:function(i,j){return this.editor.serializer.serialize(this.dataToImg(i,j),{forced_root_block:"",force_absolute:j})},htmlToData:function(k){var j,i,l;l={type:"flash",video:{sources:[]},params:{}};j=this.editor.parser.parse(k);i=j.getAll("img")[0];if(i){l=g.parse(i.attr("data-mce-json"));l.type=this.getType(i.attr("class")).name.toLowerCase();tinymce.each(d,function(m){var n=i.attr(m);if(n){l[m]=n}})}return l},getType:function(m){var k,j,l;j=tinymce.explode(m," ");for(k=0;k<j.length;k++){l=this.lookup[j[k]];if(l){return l}}},imgToObject:function(z,o){var u=this,p=u.editor,C,H,j,t,I,y,G,w,k,E,s,q,A,D,m,x,l,B,F;function r(i,n){var M,L,N,K,J;J=p.getParam("flash_video_player_url",u.convertUrl(u.url+"/moxieplayer.swf"));if(J){M=p.documentBaseURI;G.params.src=J;if(p.getParam("flash_video_player_absvideourl",true)){i=M.toAbsolute(i||"",true);n=M.toAbsolute(n||"",true)}N="";L=p.getParam("flash_video_player_flashvars",{url:"$url",poster:"$poster"});tinymce.each(L,function(P,O){P=P.replace(/\$url/,i||"");P=P.replace(/\$poster/,n||"");if(P.length>0){N+=(N?"&":"")+O+"="+escape(P)}});if(N.length){G.params.flashvars=N}K=p.getParam("flash_video_player_params",{allowfullscreen:true,allowscriptaccess:true});tinymce.each(K,function(P,O){G.params[O]=""+P})}}G=z.attr("data-mce-json");if(!G){return}G=g.parse(G);q=this.getType(z.attr("class"));B=z.attr("data-mce-style");if(!B){B=z.attr("style");if(B){B=p.dom.serializeStyle(p.dom.parseStyle(B,"img"))}}if(q.name==="Iframe"){x=new b("iframe",1);tinymce.each(d,function(i){var n=z.attr(i);if(i=="class"&&n){n=n.replace(/mceItem.+ ?/g,"")}if(n&&n.length>0){x.attr(i,n)}});for(I in G.params){x.attr(I,G.params[I])}x.attr({style:B,src:G.params.src});z.replace(x);return}if(this.editor.settings.media_use_script){x=new b("script",1).attr("type","text/javascript");y=new b("#text",3);y.value="write"+q.name+"("+g.serialize(tinymce.extend(G.params,{width:z.attr("width"),height:z.attr("height")}))+");";x.append(y);z.replace(x);return}if(q.name==="Video"&&G.video.sources[0]){C=new b("video",1).attr(tinymce.extend({id:z.attr("id"),width:z.attr("width"),height:z.attr("height"),style:B},G.video.attrs));if(G.video.attrs){l=G.video.attrs.poster}k=G.video.sources=c(G.video.sources);for(A=0;A<k.length;A++){if(/\.mp4$/.test(k[A].src)){m=k[A].src}}if(!k[0].type){C.attr("src",k[0].src);k.splice(0,1)}for(A=0;A<k.length;A++){w=new b("source",1).attr(k[A]);w.shortEnded=true;C.append(w)}if(m){r(m,l);q=u.getType("flash")}else{G.params.src=""}}if(q.name==="Audio"&&G.video.sources[0]){F=new b("audio",1).attr(tinymce.extend({id:z.attr("id"),width:z.attr("width"),height:z.attr("height"),style:B},G.video.attrs));if(G.video.attrs){l=G.video.attrs.poster}k=G.video.sources=c(G.video.sources);if(!k[0].type){F.attr("src",k[0].src);k.splice(0,1)}for(A=0;A<k.length;A++){w=new b("source",1).attr(k[A]);w.shortEnded=true;F.append(w)}G.params.src=""}if(q.name==="EmbeddedAudio"){j=new b("embed",1);j.shortEnded=true;j.attr({id:z.attr("id"),width:z.attr("width"),height:z.attr("height"),style:B,type:z.attr("type")});for(I in G.params){j.attr(I,G.params[I])}tinymce.each(d,function(i){if(G[i]&&i!="type"){j.attr(i,G[i])}});G.params.src=""}if(G.params.src){if(/\.flv$/i.test(G.params.src)){r(G.params.src,"")}if(o&&o.force_absolute){G.params.src=p.documentBaseURI.toAbsolute(G.params.src)}H=new b("object",1).attr({id:z.attr("id"),width:z.attr("width"),height:z.attr("height"),style:B});tinymce.each(d,function(i){var n=G[i];if(i=="class"&&n){n=n.replace(/mceItem.+ ?/g,"")}if(n&&i!="type"){H.attr(i,n)}});for(I in G.params){s=new b("param",1);s.shortEnded=true;y=G.params[I];if(I==="src"&&q.name==="WindowsMedia"){I="url"}s.attr({name:I,value:y});H.append(s)}if(this.editor.getParam("media_strict",true)){H.attr({data:G.params.src,type:q.mimes[0]})}else{H.attr({classid:"clsid:"+q.clsids[0],codebase:q.codebase});j=new b("embed",1);j.shortEnded=true;j.attr({id:z.attr("id"),width:z.attr("width"),height:z.attr("height"),style:B,type:q.mimes[0]});for(I in G.params){j.attr(I,G.params[I])}tinymce.each(d,function(i){if(G[i]&&i!="type"){j.attr(i,G[i])}});H.append(j)}if(G.object_html){y=new b("#text",3);y.raw=true;y.value=G.object_html;H.append(y)}if(C){C.append(H)}}if(C){if(G.video_html){y=new b("#text",3);y.raw=true;y.value=G.video_html;C.append(y)}}if(F){if(G.video_html){y=new b("#text",3);y.raw=true;y.value=G.video_html;F.append(y)}}var v=C||F||H||j;if(v){z.replace(v)}else{z.remove()}},objectToImg:function(C){var L,k,F,s,M,N,y,A,x,G,E,t,q,I,B,l,K,o,H=this.lookup,m,z,v=this.editor.settings.url_converter,n=this.editor.settings.url_converter_scope,w,r,D,j;function u(i){return new tinymce.html.Serializer({inner:true,validate:false}).serialize(i)}function J(O,i){return H[(O.attr(i)||"").toLowerCase()]}function p(O){var i=O.replace(/^.*\.([^.]+)$/,"$1");return H[i.toLowerCase()||""]}if(!C.parent){return}if(C.name==="script"){if(C.firstChild){m=a.exec(C.firstChild.value)}if(!m){return}o=m[1];K={video:{},params:g.parse(m[2])};A=K.params.width;x=K.params.height}K=K||{video:{},params:{}};M=new b("img",1);M.attr({src:this.editor.theme.url+"/img/trans.gif"});N=C.name;if(N==="video"||N=="audio"){F=C;L=C.getAll("object")[0];k=C.getAll("embed")[0];A=F.attr("width");x=F.attr("height");y=F.attr("id");K.video={attrs:{},sources:[]};z=K.video.attrs;for(N in F.attributes.map){z[N]=F.attributes.map[N]}B=C.attr("src");if(B){K.video.sources.push({src:v.call(n,B,"src",C.name)})}l=F.getAll("source");for(E=0;E<l.length;E++){B=l[E].remove();K.video.sources.push({src:v.call(n,B.attr("src"),"src","source"),type:B.attr("type"),media:B.attr("media")})}if(z.poster){z.poster=v.call(n,z.poster,"poster",C.name)}}if(C.name==="object"){L=C;k=C.getAll("embed")[0]}if(C.name==="embed"){k=C}if(C.name==="iframe"){s=C;o="Iframe"}if(L){A=A||L.attr("width");x=x||L.attr("height");G=G||L.attr("style");y=y||L.attr("id");w=w||L.attr("hspace");r=r||L.attr("vspace");D=D||L.attr("align");j=j||L.attr("bgcolor");K.name=L.attr("name");I=L.getAll("param");for(E=0;E<I.length;E++){q=I[E];N=q.remove().attr("name");if(!h[N]){K.params[N]=q.attr("value")}}K.params.src=K.params.src||L.attr("data")}if(k){A=A||k.attr("width");x=x||k.attr("height");G=G||k.attr("style");y=y||k.attr("id");w=w||k.attr("hspace");r=r||k.attr("vspace");D=D||k.attr("align");j=j||k.attr("bgcolor");for(N in k.attributes.map){if(!h[N]&&!K.params[N]){K.params[N]=k.attributes.map[N]}}}if(s){A=s.attr("width");x=s.attr("height");G=G||s.attr("style");y=s.attr("id");w=s.attr("hspace");r=s.attr("vspace");D=s.attr("align");j=s.attr("bgcolor");tinymce.each(d,function(i){M.attr(i,s.attr(i))});for(N in s.attributes.map){if(!h[N]&&!K.params[N]){K.params[N]=s.attributes.map[N]}}}if(K.params.movie){K.params.src=K.params.src||K.params.movie;delete K.params.movie}if(K.params.src){K.params.src=v.call(n,K.params.src,"src","object")}if(F){if(C.name==="video"){o=H.video.name}else{if(C.name==="audio"){o=H.audio.name}}}if(L&&!o){o=(J(L,"clsid")||J(L,"classid")||J(L,"type")||{}).name}if(k&&!o){o=(J(k,"type")||p(K.params.src)||{}).name}if(k&&o=="EmbeddedAudio"){K.params.type=k.attr("type")}C.replace(M);if(k){k.remove()}if(L){t=u(L.remove());if(t){K.object_html=t}}if(F){t=u(F.remove());if(t){K.video_html=t}}K.hspace=w;K.vspace=r;K.align=D;K.bgcolor=j;M.attr({id:y,"class":"mceItemMedia mceItem"+(o||"Flash"),style:G,width:A||(C.name=="audio"?"300":"320"),height:x||(C.name=="audio"?"32":"240"),hspace:w,vspace:r,align:D,bgcolor:j,"data-mce-json":g.serialize(K,"'")})}});tinymce.PluginManager.add("media",tinymce.plugins.MediaPlugin)})();
\ No newline at end of file
+(function(){var b=tinymce.explode("id,name,width,height,style,align,class,hspace,vspace,bgcolor,type"),a=tinymce.makeMap(b.join(",")),f=tinymce.html.Node,d,i,h=tinymce.util.JSON,g;d=[["Flash","d27cdb6e-ae6d-11cf-96b8-444553540000","application/x-shockwave-flash","http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0"],["ShockWave","166b1bca-3f9c-11cf-8075-444553540000","application/x-director","http://download.macromedia.com/pub/shockwave/cabs/director/sw.cab#version=8,5,1,0"],["WindowsMedia","6bf52a52-394a-11d3-b153-00c04f79faa6,22d6f312-b0f6-11d0-94ab-0080c74c7e95,05589fa1-c356-11ce-bf01-00aa0055595a","application/x-mplayer2","http://activex.microsoft.com/activex/controls/mplayer/en/nsmp2inf.cab#Version=5,1,52,701"],["QuickTime","02bf25d5-8c17-4b23-bc80-d3488abddc6b","video/quicktime","http://www.apple.com/qtactivex/qtplugin.cab#version=6,0,2,0"],["RealMedia","cfcdaa03-8be4-11cf-b84b-0020afbbccfa","audio/x-pn-realaudio-plugin","http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0"],["Java","8ad9c840-044e-11d1-b3e9-00805f499d93","application/x-java-applet","http://java.sun.com/products/plugin/autodl/jinstall-1_5_0-windows-i586.cab#Version=1,5,0,0"],["Silverlight","dfeaf541-f3e1-4c24-acac-99c30715084a","application/x-silverlight-2"],["Iframe"],["Video"],["EmbeddedAudio"],["Audio"]];function e(j){return typeof(j)=="string"?j.replace(/[^0-9%]/g,""):j}function c(m){var l,j,k;if(m&&!m.splice){j=[];for(k=0;true;k++){if(m[k]){j[k]=m[k]}else{break}}return j}return m}tinymce.create("tinymce.plugins.MediaPlugin",{init:function(n,j){var r=this,l={},m,p,q,k;function o(s){return s&&s.nodeName==="IMG"&&n.dom.hasClass(s,"mceItemMedia")}r.editor=n;r.url=j;i="";for(m=0;m<d.length;m++){k=d[m][0];q={name:k,clsids:tinymce.explode(d[m][1]||""),mimes:tinymce.explode(d[m][2]||""),codebase:d[m][3]};for(p=0;p<q.clsids.length;p++){l["clsid:"+q.clsids[p]]=q}for(p=0;p<q.mimes.length;p++){l[q.mimes[p]]=q}l["mceItem"+k]=q;l[k.toLowerCase()]=q;i+=(i?"|":"")+k}tinymce.each(n.getParam("media_types","video=mp4,m4v,ogv,webm;silverlight=xap;flash=swf,flv;shockwave=dcr;quicktime=mov,qt,mpg,mpeg;shockwave=dcr;windowsmedia=avi,wmv,wm,asf,asx,wmx,wvx;realmedia=rm,ra,ram;java=jar;audio=mp3,ogg").split(";"),function(v){var s,u,t;v=v.split(/=/);u=tinymce.explode(v[1].toLowerCase());for(s=0;s<u.length;s++){t=l[v[0].toLowerCase()];if(t){l[u[s]]=t}}});i=new RegExp("write("+i+")\\(([^)]+)\\)");r.lookup=l;n.onPreInit.add(function(){n.schema.addValidElements("object[id|style|width|height|classid|codebase|*],param[name|value],embed[id|style|width|height|type|src|*],video[*],audio[*],source[*]");n.parser.addNodeFilter("object,embed,video,audio,script,iframe",function(s){var t=s.length;while(t--){r.objectToImg(s[t])}});n.serializer.addNodeFilter("img",function(s,u,t){var v=s.length,w;while(v--){w=s[v];if((w.attr("class")||"").indexOf("mceItemMedia")!==-1){r.imgToObject(w,t)}}})});n.onInit.add(function(){if(n.theme&&n.theme.onResolveName){n.theme.onResolveName.add(function(s,t){if(t.name==="img"&&n.dom.hasClass(t.node,"mceItemMedia")){t.name="media"}})}if(n&&n.plugins.contextmenu){n.plugins.contextmenu.onContextMenu.add(function(t,u,s){if(s.nodeName==="IMG"&&s.className.indexOf("mceItemMedia")!==-1){u.add({title:"media.edit",icon:"media",cmd:"mceMedia"})}})}});n.addCommand("mceMedia",function(){var t,s;s=n.selection.getNode();if(o(s)){t=n.dom.getAttrib(s,"data-mce-json");if(t){t=h.parse(t);tinymce.each(b,function(u){var v=n.dom.getAttrib(s,u);if(v){t[u]=v}});t.type=r.getType(s.className).name.toLowerCase()}}if(!t){t={type:"flash",video:{sources:[]},params:{}}}n.windowManager.open({file:j+"/media.htm",width:430+parseInt(n.getLang("media.delta_width",0)),height:500+parseInt(n.getLang("media.delta_height",0)),inline:1},{plugin_url:j,data:t})});n.addButton("media",{title:"media.desc",cmd:"mceMedia"});n.onNodeChange.add(function(t,s,u){s.setActive("media",o(u))})},convertUrl:function(l,o){var k=this,n=k.editor,m=n.settings,p=m.url_converter,j=m.url_converter_scope||k;if(!l){return l}if(o){return n.documentBaseURI.toAbsolute(l)}return p.call(j,l,"src","object")},getInfo:function(){return{longname:"Media",author:"Moxiecode Systems AB",authorurl:"http://tinymce.moxiecode.com",infourl:"http://wiki.moxiecode.com/index.php/TinyMCE:Plugins/media",version:tinymce.majorVersion+"."+tinymce.minorVersion}},dataToImg:function(m,k){var r=this,o=r.editor,p=o.documentBaseURI,j,q,n,l;m.params.src=r.convertUrl(m.params.src,k);q=m.video.attrs;if(q){q.src=r.convertUrl(q.src,k)}if(q){q.poster=r.convertUrl(q.poster,k)}j=c(m.video.sources);if(j){for(l=0;l<j.length;l++){j[l].src=r.convertUrl(j[l].src,k)}}n=r.editor.dom.create("img",{id:m.id,style:m.style,align:m.align,hspace:m.hspace,vspace:m.vspace,src:r.editor.theme.url+"/img/trans.gif","class":"mceItemMedia mceItem"+r.getType(m.type).name,"data-mce-json":h.serialize(m,"'")});n.width=m.width=e(m.width||(m.type=="audio"?"300":"320"));n.height=m.height=e(m.height||(m.type=="audio"?"32":"240"));return n},dataToHtml:function(j,k){return this.editor.serializer.serialize(this.dataToImg(j,k),{forced_root_block:"",force_absolute:k})},htmlToData:function(l){var k,j,m;m={type:"flash",video:{sources:[]},params:{}};k=this.editor.parser.parse(l);j=k.getAll("img")[0];if(j){m=h.parse(j.attr("data-mce-json"));m.type=this.getType(j.attr("class")).name.toLowerCase();tinymce.each(b,function(n){var o=j.attr(n);if(o){m[n]=o}})}return m},getType:function(m){var k,j,l;j=tinymce.explode(m," ");for(k=0;k<j.length;k++){l=this.lookup[j[k]];if(l){return l}}},imgToObject:function(z,o){var u=this,p=u.editor,C,H,j,t,I,y,G,w,k,E,s,q,A,D,m,x,l,B,F;function r(n,J){var N,M,O,L,K;K=p.getParam("flash_video_player_url",u.convertUrl(u.url+"/moxieplayer.swf"));if(K){N=p.documentBaseURI;G.params.src=K;if(p.getParam("flash_video_player_absvideourl",true)){n=N.toAbsolute(n||"",true);J=N.toAbsolute(J||"",true)}O="";M=p.getParam("flash_video_player_flashvars",{url:"$url",poster:"$poster"});tinymce.each(M,function(Q,P){Q=Q.replace(/\$url/,n||"");Q=Q.replace(/\$poster/,J||"");if(Q.length>0){O+=(O?"&":"")+P+"="+escape(Q)}});if(O.length){G.params.flashvars=O}L=p.getParam("flash_video_player_params",{allowfullscreen:true,allowscriptaccess:true});tinymce.each(L,function(Q,P){G.params[P]=""+Q})}}G=z.attr("data-mce-json");if(!G){return}try{G=JSON.parse(G);}catch(e){return;}q=this.getType(z.attr("class"));B=z.attr("data-mce-style");if(!B){B=z.attr("style");if(B){B=p.dom.serializeStyle(p.dom.parseStyle(B,"img"))}}G.width=z.attr("width")||G.width;G.height=z.attr("height")||G.height;if(q.name==="Iframe"){x=new f("iframe",1);tinymce.each(b,function(n){var J=z.attr(n);if(n=="class"&&J){J=J.replace(/mceItem.+ ?/g,"")}if(J&&J.length>0){x.attr(n,J)}});for(I in G.params){x.attr(I,G.params[I])}x.attr({style:B,src:G.params.src});z.replace(x);return}if(this.editor.settings.media_use_script){x=new f("script",1).attr("type","text/javascript");y=new f("#text",3);y.value="write"+q.name+"("+h.serialize(tinymce.extend(G.params,{width:z.attr("width"),height:z.attr("height")}))+");";x.append(y);z.replace(x);return}if(q.name==="Video"&&G.video.sources[0]){C=new f("video",1).attr(tinymce.extend({id:z.attr("id"),width:e(z.attr("width")),height:e(z.attr("height")),style:B},G.video.attrs));if(G.video.attrs){l=G.video.attrs.poster}k=G.video.sources=c(G.video.sources);for(A=0;A<k.length;A++){if(/\.mp4$/.test(k[A].src)){m=k[A].src}}if(!k[0].type){C.attr("src",k[0].src);k.splice(0,1)}for(A=0;A<k.length;A++){w=new f("source",1).attr(k[A]);w.shortEnded=true;C.append(w)}if(m){r(m,l);q=u.getType("flash")}else{G.params.src=""}}if(q.name==="Audio"&&G.video.sources[0]){F=new f("audio",1).attr(tinymce.extend({id:z.attr("id"),width:e(z.attr("width")),height:e(z.attr("height")),style:B},G.video.attrs));if(G.video.attrs){l=G.video.attrs.poster}k=G.video.sources=c(G.video.sources);if(!k[0].type){F.attr("src",k[0].src);k.splice(0,1)}for(A=0;A<k.length;A++){w=new f("source",1).attr(k[A]);w.shortEnded=true;F.append(w)}G.params.src=""}if(q.name==="EmbeddedAudio"){j=new f("embed",1);j.shortEnded=true;j.attr({id:z.attr("id"),width:e(z.attr("width")),height:e(z.attr("height")),style:B,type:z.attr("type")});for(I in G.params){j.attr(I,G.params[I])}tinymce.each(b,function(n){if(G[n]&&n!="type"){j.attr(n,G[n])}});G.params.src=""}if(G.params.src){if(/\.flv$/i.test(G.params.src)){r(G.params.src,"")}if(o&&o.force_absolute){G.params.src=p.documentBaseURI.toAbsolute(G.params.src)}H=new f("object",1).attr({id:z.attr("id"),width:e(z.attr("width")),height:e(z.attr("height")),style:B});tinymce.each(b,function(n){var J=G[n];if(n=="class"&&J){J=J.replace(/mceItem.+ ?/g,"")}if(J&&n!="type"){H.attr(n,J)}});for(I in G.params){s=new f("param",1);s.shortEnded=true;y=G.params[I];if(I==="src"&&q.name==="WindowsMedia"){I="url"}s.attr({name:I,value:y});H.append(s)}if(this.editor.getParam("media_strict",true)){H.attr({data:G.params.src,type:q.mimes[0]})}else{H.attr({classid:"clsid:"+q.clsids[0],codebase:q.codebase});j=new f("embed",1);j.shortEnded=true;j.attr({id:z.attr("id"),width:e(z.attr("width")),height:e(z.attr("height")),style:B,type:q.mimes[0]});for(I in G.params){j.attr(I,G.params[I])}tinymce.each(b,function(n){if(G[n]&&n!="type"){j.attr(n,G[n])}});H.append(j)}if(G.object_html){y=new f("#text",3);y.raw=true;y.value=G.object_html;H.append(y)}if(C){C.append(H)}}if(C){if(G.video_html){y=new f("#text",3);y.raw=true;y.value=G.video_html;C.append(y)}}if(F){if(G.video_html){y=new f("#text",3);y.raw=true;y.value=G.video_html;F.append(y)}}var v=C||F||H||j;if(v){z.replace(v)}else{z.remove()}},objectToImg:function(C){var L,k,F,s,M,N,y,A,x,G,E,t,q,I,B,l,K,o,H=this.lookup,m,z,v=this.editor.settings.url_converter,n=this.editor.settings.url_converter_scope,w,r,D,j;function u(O){return new tinymce.html.Serializer({inner:true,validate:false}).serialize(O)}function J(P,O){return H[(P.attr(O)||"").toLowerCase()]}function p(P){var O=P.replace(/^.*\.([^.]+)$/,"$1");return H[O.toLowerCase()||""]}if(!C.parent){return}if(C.name==="script"){if(C.firstChild){m=i.exec(C.firstChild.value)}if(!m){return}o=m[1];K={video:{},params:h.parse(m[2])};A=K.params.width;x=K.params.height}K=K||{video:{},params:{}};M=new f("img",1);M.attr({src:this.editor.theme.url+"/img/trans.gif"});N=C.name;if(N==="video"||N=="audio"){F=C;L=C.getAll("object")[0];k=C.getAll("embed")[0];A=F.attr("width");x=F.attr("height");y=F.attr("id");K.video={attrs:{},sources:[]};z=K.video.attrs;for(N in F.attributes.map){z[N]=F.attributes.map[N]}B=C.attr("src");if(B){K.video.sources.push({src:v.call(n,B,"src",C.name)})}l=F.getAll("source");for(E=0;E<l.length;E++){B=l[E].remove();K.video.sources.push({src:v.call(n,B.attr("src"),"src","source"),type:B.attr("type"),media:B.attr("media")})}if(z.poster){z.poster=v.call(n,z.poster,"poster",C.name)}}if(C.name==="object"){L=C;k=C.getAll("embed")[0]}if(C.name==="embed"){k=C}if(C.name==="iframe"){s=C;o="Iframe"}if(L){A=A||L.attr("width");x=x||L.attr("height");G=G||L.attr("style");y=y||L.attr("id");w=w||L.attr("hspace");r=r||L.attr("vspace");D=D||L.attr("align");j=j||L.attr("bgcolor");K.name=L.attr("name");I=L.getAll("param");for(E=0;E<I.length;E++){q=I[E];N=q.remove().attr("name");if(!a[N]){K.params[N]=q.attr("value")}}K.params.src=K.params.src||L.attr("data")}if(k){A=A||k.attr("width");x=x||k.attr("height");G=G||k.attr("style");y=y||k.attr("id");w=w||k.attr("hspace");r=r||k.attr("vspace");D=D||k.attr("align");j=j||k.attr("bgcolor");for(N in k.attributes.map){if(!a[N]&&!K.params[N]){K.params[N]=k.attributes.map[N]}}}if(s){A=e(s.attr("width"));x=e(s.attr("height"));G=G||s.attr("style");y=s.attr("id");w=s.attr("hspace");r=s.attr("vspace");D=s.attr("align");j=s.attr("bgcolor");tinymce.each(b,function(O){M.attr(O,s.attr(O))});for(N in s.attributes.map){if(!a[N]&&!K.params[N]){K.params[N]=s.attributes.map[N]}}}if(K.params.movie){K.params.src=K.params.src||K.params.movie;delete K.params.movie}if(K.params.src){K.params.src=v.call(n,K.params.src,"src","object")}if(F){if(C.name==="video"){o=H.video.name}else{if(C.name==="audio"){o=H.audio.name}}}if(L&&!o){o=(J(L,"clsid")||J(L,"classid")||J(L,"type")||{}).name}if(k&&!o){o=(J(k,"type")||p(K.params.src)||{}).name}if(k&&o=="EmbeddedAudio"){K.params.type=k.attr("type")}C.replace(M);if(k){k.remove()}if(L){t=u(L.remove());if(t){K.object_html=t}}if(F){t=u(F.remove());if(t){K.video_html=t}}K.hspace=w;K.vspace=r;K.align=D;K.bgcolor=j;M.attr({id:y,"class":"mceItemMedia mceItem"+(o||"Flash"),style:G,width:A||(C.name=="audio"?"300":"320"),height:x||(C.name=="audio"?"32":"240"),hspace:w,vspace:r,align:D,bgcolor:j,"data-mce-json":h.serialize(K,"'")})}});tinymce.PluginManager.add("media",tinymce.plugins.MediaPlugin)})();
\ No newline at end of file
diff --git js/tiny_mce/plugins/media/editor_plugin_src.js js/tiny_mce/plugins/media/editor_plugin_src.js
index ea79db18a76..78dd3971d43 100644
--- js/tiny_mce/plugins/media/editor_plugin_src.js
+++ js/tiny_mce/plugins/media/editor_plugin_src.js
@@ -375,7 +375,12 @@
 			if (!data)
 				return;
 
-			data = JSON.parse(data);
+			try {
+				data = JSON.parse(data);
+			} catch (e) {
+				return;
+			}
+
 			typeItem = this.getType(node.attr('class'));
 
 			style = node.attr('data-mce-style')
diff --git js/varien/js.js js/varien/js.js
index 1e483811aac..952b8758d50 100644
--- js/varien/js.js
+++ js/varien/js.js
@@ -744,3 +744,19 @@ function customFormSubmit(url, parametersArray, method) {
     Element.insert($$('body')[0], createdForm.form);
     createdForm.form.submit();
 }
+
+function customFormSubmitToParent(url, parametersArray, method) {
+    new Ajax.Request(url, {
+        method: method,
+        parameters: JSON.parse(parametersArray),
+        onSuccess: function (response) {
+            var node = document.createElement('div');
+            node.innerHTML = response.responseText;
+            var responseMessage = node.getElementsByClassName('messages')[0];
+            var pageTitle = window.document.body.getElementsByClassName('page-title')[0];
+            pageTitle.insertAdjacentHTML('afterend', responseMessage.outerHTML);
+            window.opener.focus();
+            window.opener.location.href = response.transport.responseURL;
+        }
+    });
+}
diff --git lib/Varien/Filter/FormElementName.php lib/Varien/Filter/FormElementName.php
index 888e1e9fff7..da37a369d11 100644
--- lib/Varien/Filter/FormElementName.php
+++ lib/Varien/Filter/FormElementName.php
@@ -1,12 +1,29 @@
 <?php
 /**
- * {license_notice}
+ * Magento
  *
- * @copyright   {copyright}
- * @license     {license_link}
+ * NOTICE OF LICENSE
+ *
+ * This source file is subject to the Open Software License (OSL 3.0)
+ * that is bundled with this package in the file LICENSE.txt.
+ * It is also available through the world-wide-web at this URL:
+ * http://opensource.org/licenses/osl-3.0.php
+ * If you did not receive a copy of the license and are unable to
+ * obtain it through the world-wide-web, please send an email
+ * to license@magento.com so we can send you a copy immediately.
+ *
+ * DISCLAIMER
+ *
+ * Do not edit or add to this file if you wish to upgrade Magento to newer
+ * versions in the future. If you wish to customize Magento for your
+ * needs please refer to http://www.magento.com for more information.
+ *
+ * @category    Varien
+ * @package     Varien_Filter
+ * @copyright  Copyright (c) 2006-2019 Magento, Inc. (http://www.magento.com)
+ * @license    http://opensource.org/licenses/osl-3.0.php  Open Software License (OSL 3.0)
  */
 
-
 class Varien_Filter_FormElementName extends Zend_Filter_Alnum
 {
     /**
diff --git skin/adminhtml/default/default/boxes.css skin/adminhtml/default/default/boxes.css
index 59d36258831..2a66ae316fc 100644
--- skin/adminhtml/default/default/boxes.css
+++ skin/adminhtml/default/default/boxes.css
@@ -1592,6 +1592,7 @@ ul.super-product-attributes { padding-left:15px; }
 .wrap               { white-space:normal !important; }
 .no-float           { float:none !important; }
 .pointer            { cursor:pointer; }
+.half               { width:50%; }
 
 /* Color */
 .emph, .accent      { color:#eb5e00 !important; }
