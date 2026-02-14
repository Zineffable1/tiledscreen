/*
 SPDX-FileCopyrightText: 2024 Kavinu Nethsara <kavinunethsarakoswattage@gmail.com>
 SPDX-License-Identifier: LGPL-2.1-or-later
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item{
    id: root
    property string title
    property bool titleVisible: true
    property string action
    property bool actionVisible: true
    property bool hasSearch: false
    property bool searchBarAlwaysVisible: false
    property bool fill: false
    property alias useBackground: containerItem.useBackground
    property alias searchText: search.text
    property alias textField: search
    default property alias content: containerItem.content

    signal activated

    height: mainLayout.implicitHeight
    Layout.fillWidth: true
    Layout.minimumWidth: mainLayout.implicitWidth
    
    focus: true
    activeFocusOnTab: true
    
    Keys.onPressed: (event) => {
        // ALWAYS handle character input for search (even if tiles/apps are focused)
        if (root.hasSearch) {
            if ((event.text.length > 0 && event.text[0].match(/[a-zA-Z0-9 ]/)) || event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete) {
                if (!search.activeFocus) {
                    // TextField doesn't have focus - we need to transfer it and handle the key manually
                    search.forceActiveFocus();
                    
                    // Handle the character input manually since the TextField won't receive this event
                    if (event.text.length > 0 && event.text[0].match(/[a-zA-Z0-9 ]/)) {
                        search.text += event.text;
                        search.cursorPosition = search.text.length;
                    } else if (event.key === Qt.Key_Backspace && search.text.length > 0) {
                        search.text = search.text.substring(0, search.text.length - 1);
                        search.cursorPosition = search.text.length;
                    } else if (event.key === Qt.Key_Delete && search.cursorPosition < search.text.length) {
                        search.text = search.text.substring(0, search.cursorPosition) + 
                                     search.text.substring(search.cursorPosition + 1);
                    }
                    event.accepted = true;
                } else {
                    // TextField already has focus - let it handle the event normally
                    event.accepted = false;
                }
                return;
            }
        }
        
        // Arrow keys should focus content when search is empty
        if (event.key === Qt.Key_Up || event.key === Qt.Key_Down || 
            event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
            
            if (search.text.length === 0) {
                // Don't accept the event - let it propagate to focused children
                // But ensure content has focus first
                var hasFocusedChild = false
                for (var i = 0; i < root.content.length; i++) {
                    var item = root.content[i]
                    if (item.visible && item.activeFocus) {
                        hasFocusedChild = true
                        break
                    }
                }
                
                if (!hasFocusedChild) {
                    // Focus first visible content item
                    for (var j = 0; j < root.content.length; j++) {
                        var contentItem = root.content[j]
                        if (contentItem.visible && contentItem.focus !== undefined) {
                            contentItem.forceActiveFocus()
                            // Don't accept - let the newly focused item handle the arrow key
                            event.accepted = false
                            return
                        }
                    }
                }
                // If already focused, don't accept - let child handle it
                event.accepted = false
                return
            }
        }
    }
    
    ColumnLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: root.fill? parent.top : undefined
        anchors.bottom: root.fill? parent.bottom : undefined
        //spacing: Kirigami.Units.smallSpacing * 2

        Item {
            Layout.preferredHeight: actionButton.implicitHeight
            Layout.fillWidth: true

            PlasmaComponents.Label {
                visible: root.titleVisible
                text: root.title
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
            }
            PlasmaComponents.TextField {
                id: search
                visible: root.hasSearch && (root.searchBarAlwaysVisible || search.text.length > 0)
                implicitWidth: Kirigami.Units.gridUnit * 15
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                placeholderText: "Search..."
                Keys.onEscapePressed: {
                    event.accepted = false;
                }
            }
            PlasmaComponents.Button {
                id: actionButton

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                text: root.action
                visible: root.action && root.actionVisible
                onClicked: root.activated();
            }
        }

        Card {
            id: containerItem
            Layout.fillHeight: root.fill? true : false
        }
    }

    function grabFocus () {
        if (!root.searchBarAlwaysVisible) {
            search.forceActiveFocus();
        }
    }
}
