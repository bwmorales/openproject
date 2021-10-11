import {
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Component,
  Input,
  HostBinding,
} from '@angular/core';
import { I18nService } from 'core-app/core/i18n/i18n.service';

export interface IOpSidemenuItem {
  title:string;
  icon?:string;
  count?:number;
  href?:string;
  uiSref?:string;
  uiParams?:any;
  children?:IOpSidemenuItem[];
  collapsible?:boolean;
}

@Component({
  selector: 'op-sidemenu',
  templateUrl: './sidemenu.component.html',
  styleUrls: ['./sidemenu.component.sass'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class OpSidemenuComponent {
  @HostBinding('class.op-sidemenu') className = true;

  @HostBinding('class.op-sidemenu_collapsed') collapsed = false;

  @Input() items:IOpSidemenuItem[] = [];

  @Input() title:string;

  @Input() collapsible = true;

  constructor(
    readonly cdRef:ChangeDetectorRef,
    readonly I18n:I18nService,
  ) { }

  toggleCollapsed():void {
    this.collapsed = !this.collapsed;
  }
}
