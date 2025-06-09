import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';
import { Command } from '../model/command';
import Log from '../utils/Log';

let storage = LocalStorage.getShared();

@Entry
@Component
struct Tsc {
  @LocalStorageProp('commandList') commandList: Command[] = []
  @StorageLink('receivedList') @Watch('onCommandChange') receivedList: Command[] = []
  @State currentCommand: Command = Command.END
  @State snake: Array<[number, number]> = [[18, 25], [18, 26]]
  @State food: [number, number] = [20, 20]
  @State moveDir: number = 0
  @State score: number = 0
  private gridSize: number = 10
  private xGridCells: number = 48
  private yGridCells: number = 76
  private timer: number = 0
  @State isPlaying: boolean = false
  @State isStopped: boolean = false

  onCommandChange() {
    this.currentCommand = (this.receivedList[this.receivedList.length - 1]) as Command
    Log.info('onCommandChange', this.receivedList[this.receivedList.length-1])
    Log.info('current command: ', this.currentCommand)

    if (this.currentCommand.toString() === '[0]') {
      this.startGame()
    }

    switch (this.currentCommand.toString()) {
      case '[0]':
        this.startGame()
        break
      case '[1]':
        this.startGame()
        break
      case '[2]':
        this.endGame()
        break
      case '[3]':
        this.moveDir = 0;
        break
      case '[4]':
        this.moveDir = 1;
        break
      case '[5]':
        this.moveDir = 2;
        break
      case '[6]':
        this.moveDir = 3;
        break
      case '[7]':
        this.stopGame()
        break
      case '[8]':
        this.continueGame()
        break
    }
  }

  fillGrids(): Array<[number, number]> {
    let allPositions: Array<[number, number]> = []
    for (let x = 0; x < this.xGridCells; x++) {
      for (let y = 0; y < this.yGridCells; y++) {
        allPositions.push([x, y])
      }
    }
    return allPositions
  }

  checkFoodOverlap(foodPos: [number, number]): boolean {
    if (this.snake.some(body => {
      body[0] === foodPos[0] && body[1] === foodPos[1]
    }))
      return true
    return false
  }

  generateNewFood() {
    const availablePositions = this.fillGrids().filter(pos =>!this.checkFoodOverlap(pos))
    if (availablePositions.length > 0) {
      const randIndex = Math.floor(Math.random() * availablePositions.length)
      this.food = availablePositions[randIndex]
    }
  }

  startGame() {
    if (this.timer) {
      clearInterval(this.timer)
    }
    this.isPlaying = true

    this.resetGame()

    this.timer = setInterval(() => {
      this.moveSnake()
    }, 500)
  }

  moveSnake() {
    let head: [number, number] = [this.snake[0][0], this.snake[0][1]]

    switch (this.moveDir) {
      case 0:
        head[1] -= 1
        break
      case 1:
        head[1] += 1
        break
      case 2:
        head[0] -= 1
        break
      case 3:
        head[0] += 1
        break
    }

    if (head[0] < 0 || head[0] >= this.xGridCells || head[1] < 0 || head[1] >= this.yGridCells) {
      this.endGame()
      return
    }

    // eat food
    if (head[0] === this.food[0] && head[1] === this.food[1]) {
      this.generateNewFood()
      this.score += 10
      this.snake = [head, ...this.snake]
    } else {
      this.snake.pop()
      this.snake = [head, ...this.snake]
    }
  }

  endGame() {
    if (!this.isPlaying) {
      return
    }
    clearInterval(this.timer)
    this.timer = 0
    this.isPlaying = false
    promptAction.showToast({
      message: `Game Over! Final score: ${this.score}`
    })
  }

  resetGame() {
    this.snake = [[18, 25], [18, 26]]
    this.moveDir = 0
    this.score = 0
    this.generateNewFood()
  }

  stopGame() {
    this.isStopped = true
    this.isPlaying = false
    clearInterval(this.timer)
  }

  continueGame() {
    this.isStopped = false
    this.isPlaying = true
    this.timer = setInterval(() => {
      this.moveSnake()
    }, 500)
  }

  build() {
    Column() {
      Stack() {
        Text(`score:${this.score}`)
        Circle({ width: this.gridSize, height: this.gridSize })
          .fill(Color.Orange)
          .strokeWidth(2)
          .position({
            x: this.food[0] * this.gridSize,
            y: this.food[1] * this.gridSize
          })

        ForEach(this.snake, (body: [number, number], index: number) => {
          if (index === 0) {
            Circle({ width: this.gridSize, height: this.gridSize })
              .fill(Color.Blue)
              .position({
                x: body[0] * this.gridSize,
                y: body[1] * this.gridSize
              })
          } else {
            Circle({ width: this.gridSize, height: this.gridSize })
              .fill(Color.Gray)
              .position({
                x: body[0] * this.gridSize,
                y: body[1] * this.gridSize
              })
          }
        })
      }
      .width('100%')
      .height('100%')
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