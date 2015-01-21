package;

import flash.Lib;
import flash.display.Sprite;
import ru.stablex.ui.UIBuilder;


class Main extends Sprite{

    static public function main () : Void{

    //initialize StablexUI
    UIBuilder.init();
    // Congratulations! You can use StablexUI!
    flash.Lib.current.addChild( UIBuilder.buildFn('first.xml')() );

    }
}
