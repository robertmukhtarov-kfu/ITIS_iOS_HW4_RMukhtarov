//
//  ViewController.swift
//  hw4
//
//  Created by Robert Mukhtarov on 08.11.2021.
//

import UIKit
import SnapKit
import Combine

final class ViewController: UIViewController {

    // MARK: - Layout Constants

    private enum LayoutConstants {
        enum CatsDogsSegmentedControl {
            static let topOffset = 21.0
            static let width = 196.0
        }

        enum ContentView {
            static let topOffset = 35.0
            static let horizontalInset = 18.0
            static let heightToWidthRatio = 0.6
        }

        enum MoreButton {
            static let topOffset = 12.63
        }

        enum ScoreLabel {
            static let topOffset = 19.0
            static let fontSize = 16.0
        }
    }

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var catCounter = CurrentValueSubject<Int, Never>(0)
    private var dogCounter = CurrentValueSubject<Int, Never>(0)

    // MARK: - Views

    private lazy var catsDogsSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Cats", "Dogs"])
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return segmentedControl
    }()

    private lazy var moreButton: MoreButton = {
        let button = MoreButton()
        button.addTarget(self, action: #selector(moreButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var contentView = ContentView()

    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: LayoutConstants.ScoreLabel.fontSize)
        return label
    }()

    private lazy var resetBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(
            title: "Reset",
            style: .plain,
            target: self,
            action: #selector(resetBarButtonPressed)
        )
        return barButtonItem
    }()

    // MARK: - Overridden Internal Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addSubviews()
        makeConstraints()
        setupSubscriptions()
    }

    // MARK: - Methods Related to Combine

    private func setupSubscriptions() {
        Publishers.CombineLatest(catCounter, dogCounter)
            .map { "Score: \($0) cats and \($1) dogs" }
            .assign(to: \.text, on: scoreLabel)
            .store(in: &cancellables)

        NotificationCenter.Publisher(center: .default, name: .segmentedControlValueChanged, object: catsDogsSegmentedControl)
            .sink { [unowned self] _ in triggerContentLoad() }
            .store(in: &cancellables)

        NotificationCenter.Publisher(center: .default, name: .buttonPressed, object: moreButton)
            .sink { [unowned self] _ in triggerContentLoad() }
            .store(in: &cancellables)

        NotificationCenter.Publisher(center: .default, name: .barButtonPressed, object: resetBarButtonItem)
            .sink { [unowned self] _ in reset() }
            .store(in: &cancellables)
    }

    private func loadCatFact() {
        URLSession.shared.dataTaskPublisher(for: .catsURL)
            .map(\.data)
            .decode(type: CatFact.self, decoder: JSONDecoder())
            .map(\.fact)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.contentView.setText("Failed to load a fact")
                }
            } receiveValue: { [weak self] value in
                self?.contentView.setText(value)
                self?.catCounter.value += 1
            }
            .store(in: &cancellables)
    }

    private func loadDogImage() {
        URLSession.shared.dataTaskPublisher(for: .dogsURL)
            .map(\.data)
            .decode(type: DogImage.self, decoder: JSONDecoder())
            .map(\.message)
            .replaceError(with: "")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.contentView.setImage(with: $0) {
                    self?.dogCounter.value += 1
                }
            }
            .store(in: &cancellables)
    }

    private func triggerContentLoad() {
        switch catsDogsSegmentedControl.selectedSegmentIndex {
        case 0:
            loadCatFact()
        case 1:
            loadDogImage()
        default:
            break
        }
    }

    private func reset() {
        catCounter.value = 0
        dogCounter.value = 0
        catsDogsSegmentedControl.selectedSegmentIndex = -1
        contentView.reset()
    }

    // MARK: - UIControl Actions

    @objc private func segmentedControlValueChanged(sender: UISegmentedControl) {
        NotificationCenter.default.post(name: .segmentedControlValueChanged, object: sender)
    }

    @objc private func moreButtonPressed(sender: MoreButton) {
        NotificationCenter.default.post(name: .buttonPressed, object: sender)
    }

    @objc private func resetBarButtonPressed(sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: .barButtonPressed, object: sender)
    }

    // MARK: - View Setup

    private func setupView() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = resetBarButtonItem
        title = "Cats and Dogs"
    }

    private func addSubviews() {
        view.addSubview(catsDogsSegmentedControl)
        view.addSubview(contentView)
        view.addSubview(moreButton)
        view.addSubview(scoreLabel)
    }

    private func makeConstraints() {
        catsDogsSegmentedControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(LayoutConstants.CatsDogsSegmentedControl.topOffset)
            make.width.equalTo(LayoutConstants.CatsDogsSegmentedControl.width)
        }
        contentView.snp.makeConstraints { make in
            make.top.equalTo(catsDogsSegmentedControl.snp.bottom).offset(LayoutConstants.ContentView.topOffset)
            make.height.equalTo(contentView.snp.width).multipliedBy(LayoutConstants.ContentView.heightToWidthRatio)
            make.leading.trailing.equalToSuperview().inset(LayoutConstants.ContentView.horizontalInset)
        }
        moreButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(contentView.snp.bottom).offset(LayoutConstants.MoreButton.topOffset)
        }
        scoreLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(moreButton.snp.bottom).offset(LayoutConstants.ScoreLabel.topOffset)
        }
    }
}
