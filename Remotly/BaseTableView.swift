//
//  RTTableView.swift
//  Remotly
//
//  Created by Marcin Czachurski on 29.08.2015.
//  Copyright (c) 2015 SunLine Technologies. All rights reserved.
//

import UIKit

class BaseTableView : UITableView
{
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        textFieldResignFirstResponders(self);
        super.touchesEnded(touches, withEvent: event)
    }
    
    private func textFieldResignFirstResponders(view:UIView)
    {
        for childView in view.subviews
        {
            if(childView.isKindOfClass(UITextField))
            {
                let textField = childView as! UITextField
                textField.resignFirstResponder()
            }
            else
            {
                textFieldResignFirstResponders(childView )
            }
        }
    }
}