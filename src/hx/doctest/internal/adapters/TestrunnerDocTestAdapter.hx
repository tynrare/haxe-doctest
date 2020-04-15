/*
 * Copyright (c) 2016-2020 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal.adapters;

import haxe.macro.Context;
import haxe.macro.Expr;
import hx.doctest.internal.DocTestAssertion;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:noDoc @:dox(hide)
class TestrunnerDocTestAdapter extends DocTestAdapter {

    inline
    public function new() {
    }

    override
    public function getFrameworkName():String {
        return "hx.doctest";
    }

    public function generateTestLog(assertion:DocTestAssertion, ?errorMsg:String):Expr {
        return macro {
            var success = $v{errorMsg} == null;
            results.add(
                success,
                '${assertion.expression}' + (success ? '' : ' --> $errorMsg'), 
                $v{assertion.getSourceLocation()}, 
                $v{assertion.getPosInfos(false)});
        };
    }

    override
    public function generateTestFail(assertion:DocTestAssertion, errorMsg:String):Expr {
        return generateTestLog(assertion, errorMsg);
    }

    override
    public function generateTestSuccess(assertion:DocTestAssertion):Expr {
        return generateTestLog(assertion);
    }

    override
    public function generateTestMethod(methodName:String, descr:String, assertions:Array<Expr>):Field {
        assertions.unshift(macro {
            var pos = { fileName: $v{Context.getLocalModule()}, lineNumber:1, className: $v{Context.getLocalClass().get().name}, methodName:"" };
            hx.doctest.internal.Logger.log(INFO, '**********************************************************', pos);
            hx.doctest.internal.Logger.log(INFO, '${descr}...', pos);
            hx.doctest.internal.Logger.log(INFO, '**********************************************************', pos);
        });

        return super.generateTestMethod(methodName, descr, assertions);
    }
}
