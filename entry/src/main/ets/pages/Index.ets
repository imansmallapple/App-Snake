import DeviceManager from '../utils/DeviceManager'
import DeviceListDialog from '../view/CustomDialogComponent';
import deviceManager from '@ohos.distributedDeviceManager'
import Log from '../utils/Log';
import common from '@ohos.app.ability.common';
import KvStoreModel from '../utils/kvStoreUtil';
import promptAction from '@ohos.promptAction';
import distributedKVStore from '@ohos.data.distributedKVStore';
import { Command } from '../model/command';
import router from '@ohos.router';

let storage = LocalStorage.getShared();
AppStorage.setOrCreate('receivedList', [])

@Entry(storage)
@Component
struct Index {
  @StorageLink('deviceList') deviceList: deviceManager.DeviceBasicInfo[] = []
  @StorageLink('RemoteConnectDeviceId') remoteConnectDeviceId: string = ''
  @StorageLink('isSender') isSender: boolean = false
  @StorageLink('isReceiver') @Watch('onReceiverActivate') isReceiver: boolean = false
  @StorageLink('isPaired') isPaired: boolean = false
  @LocalStorageProp('commandList') commandList: Command[] = []
  @State connectedDeviceId: string = ''
  @State receivedText: string[] = []
  @State isLoading: boolean = false
  @State isAbleUnbind: boolean = false
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  private kvStoreModel: KvStoreModel = new KvStoreModel()
  @State receivedList: Command[] = []

  aboutToAppear() {
    this.createKVStore()
    DeviceManager.clearDeviceList()
  }

  onReceiverActivate() {
    if (this.isReceiver) {
      router.pushUrl({ url: 'pages/Receiver' })
    }
  }

  createKVStore(): void {
    this.kvStoreModel.createKvStore(this.context, (data: distributedKVStore.ChangeNotification) => {
      this.commandList = []

      if (data.insertEntries.length > 0) {
        data.updateEntries.forEach((entry) => {
          Log.info('kvStore', 'inside insert', entry.key, entry.value.type, entry.value.value)
          this.receivedList = [...this.receivedList, (entry.value.value) as Command]
          Log.info('kvStore', this.receivedList)
          AppStorage.setOrCreate('receivedList', this.receivedList)
        })
      }
      if (data.updateEntries.length > 0) {
        data.updateEntries.forEach((entry) => {
          Log.info('kvStore', 'inside update', entry.key, entry.value.type, entry.value.value)
          this.receivedList = [...this.receivedList, (entry.value.value) as Command]
          Log.info('kvStore', this.receivedList)
          AppStorage.setOrCreate('receivedList', this.receivedList)
        })
      }
    })
  }

  aboutToDisappear(): void {
    this.kvStoreModel.removeDataChangeListener()
  }

  private dialogController: CustomDialogController = new CustomDialogController({
    builder: DeviceListDialog({
      startAbility: this.startAbility,
      deviceList: this.deviceList,
      cancel: this.onCancel,
      param: this.commandList,
      connectedDeviceId: this.connectedDeviceId,
      isLoading: this.isLoading,
      isPaired: this.isPaired,
    })
  })

  startFindingNearbyDevice(): void {
    DeviceManager.startDeviceDiscovery()
  }

  onCancel(): void {
    DeviceManager.stopDeviceDiscovery()
  }

  pushData(data: Command): void {
    Log.info('ConnectedDeviceId: ', this.connectedDeviceId)
    Log.info('ConnectedDeviceId data: ', data)
    this.commandList.push(data)
    this.kvStoreModel.put('sync messageList', JSON.stringify(this.commandList))
  }

  isDeviceConnected(): boolean {
    if (!this.connectedDeviceId ? 0 : !this.remoteConnectDeviceId) {
      Log.info('No device connected or text is empty!')
      return false
    }
    return true
  }

  startAbility(
    context: common.UIAbilityContext,
    device: deviceManager.DeviceBasicInfo,
    shared_list: Command[]
  ): void {
    DeviceManager.authenticateDevice(context, device, shared_list)
    DeviceManager.stopDeviceDiscovery()
  }

  build() {
    Column() {
      Row() {
        Button('Find nearby Device')
          .onClick(() => {
            this.startFindingNearbyDevice()
            this.dialogController.open()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Row() {
        Text(`${this.isSender ? 'Sender' : 'Receiver'}`)
          .alignSelf(ItemAlign.Start)

        Text(`Paired: ${this.isPaired}`)
          .alignSelf(ItemAlign.End)
      }
      .width('100%')
      .zIndex(1)
      .justifyContent(FlexAlign.End)

      if (this.isLoading) {
        LoadingProgress()
          .width(50)
      }
      if (this.connectedDeviceId !== '') {
        Button('Unbind')
          .onClick(() => {
            promptAction.showToast({ message: 'Unbind...' })
            setTimeout(() => {
              DeviceManager.unbindDevice(this.connectedDeviceId)
              this.connectedDeviceId = ''
              this.remoteConnectDeviceId = ''
            }, 100)
          })
      }
      Text('Connected device id: ' + this.remoteConnectDeviceId == '' ? this.connectedDeviceId : this.remoteConnectDeviceId)

      Column() {
        Image($r('app.media.up'))
          .width('25%')
          .onClick(() => {
            this.pushData(Command.UP)
          })

        Row({ space: 100 }) {
          Image($r('app.media.left'))
            .width('25%')
            .onClick(() => {
              this.pushData(Command.LEFT)
            })
          Image($r('app.media.right'))
            .width('25%')
            .onClick(() => {
              this.pushData(Command.RIGHT)
            })
        }

        Image($r('app.media.down'))
          .width('25%')
          .onClick(() => {
            this.pushData(Command.DOWN)
          })
      }

      Column({ space: 20 }) {
        Button('Start')
          .buttonlStyle(
            Color.Orange,
            Color.Black
          )
          .onClick(() => {
            if (!this.isDeviceConnected()) return
            this.pushData(Command.START)
          })
        Button('Stop')
          .buttonlStyle(
            Color.Orange,
            Color.Black
          )
          .onClick(() => {
            this.pushData(Command.STOP)
          })
        Button('Continue')
          .buttonlStyle(
            Color.Orange,
            Color.Black
          )
          .onClick(() => {
            this.pushData(Command.CONTINUE)
          })

        Button('Restart')
          .buttonlStyle(
            Color.Orange,
            Color.Black
          )
          .onClick(() => {
            this.pushData(Command.RESTART)
          })

        Button('End')
          .buttonlStyle(
            Color.Orange,
            Color.Black
          )
          .onClick(() => {
            this.pushData(Command.END)
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#a91effeb')
  }
}

@Extend(Button)
function buttonlStyle(
  btColor: ResourceColor,
  fontColor: ResourceColor,
) {
  .fontColor(fontColor)
  .backgroundColor(btColor)
  .height('5%')
  .type(ButtonType.Normal)
  .fontSize(17)
  // .borderWidth(1)
  .borderRadius(5)
  .fontWeight(FontWeight.Medium)
}