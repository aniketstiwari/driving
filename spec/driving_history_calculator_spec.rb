describe DrivingHistoryCalculator do

    let(:calculator) { DrivingHistoryCalculator.new }

    describe 'When only Driver entries are found' do
      it 'outputs short entries' do
        driving_records = [
          'Driver Terence',
          'Driver Alma'
        ]

        report_lines = calculator.calc(driving_records)

        expect(report_lines.length).to eq(2)
        expect(report_lines).to include('Terence: 0 miles')
        expect(report_lines).to include('Alma: 0 miles')
      end
    end

    describe 'When there is a single driver with a single trip' do
      let(:driving_records) {driving_records = [
        'Driver Terence',
        'Trip Terence 07:15 07:45 17.3'
      ]}

      it 'calculates the distance' do
        report_lines = calculator.calc(driving_records)

        expect(report_lines.length).to eq(1)
        expect(report_lines[0]).to start_with('Terence: 17 miles')
      end

      it 'calculates the speed' do
        report_lines = calculator.calc(driving_records)

        expect(report_lines.length).to eq(1)
        expect(report_lines[0]).to eq('Terence: 17 miles @ 35 mph')
      end
    end

    describe 'When there are multiple entries for a single driver' do
      it 'calculates the total distance' do
        driving_records = [
          'Driver Terence',
          'Trip Terence 07:15 07:45 17.3',
          'Trip Terence 08:00 08:15 15'
        ]

        report_lines = calculator.calc(driving_records)

        expect(report_lines.length).to eq(1)
        expect(report_lines[0]).to start_with('Terence: 32 miles')
      end

      it 'calculates the average speed' do
        driving_records = [
          'Driver Terence',
          'Trip Terence 07:15 07:45 17.3',
          'Trip Terence 08:00 08:15 15'
        ]

        report_lines = calculator.calc(driving_records)

        expect(report_lines.length).to eq(1)
        expect(report_lines[0]).to end_with('@ 43 mph')
      end
    end

    describe 'When there are mixed entries' do
      it 'includes all drivers whether they have trips or not' do
        driving_records = [
          'Driver Terence',
          'Trip Terence 07:15 07:45 17.3',
          'Driver Adam'
        ]

        report_lines = calculator.calc(driving_records)

        expect(report_lines.length).to eq(2)
        expect(report_lines[0]).to eq('Terence: 17 miles @ 35 mph')
        expect(report_lines[1]).to eq('Adam: 0 miles')
      end

      it 'includes multiple drivers with multiple trips' do
        driving_records = [
          'Driver Terence',
          'Trip Terence 07:15 07:45 17.3',
          'Driver Adam',
          'Trip Adam 06:30 06:45 10.7'
        ]

        report_lines = calculator.calc(driving_records)

        expect(report_lines.length).to eq(2)
        expect(report_lines[0]).to eq('Terence: 17 miles @ 35 mph')
        expect(report_lines[1]).to eq('Adam: 11 miles @ 43 mph')
      end

      it 'sorts trips by total distance' do
        driving_records = [
          'Driver Terence',
          'Driver Alma',
          'Driver Adam',
          'Trip Adam 06:30 06:45 10.7',
          'Trip Terence 07:15 07:45 17.3',
        ]

        report_lines = calculator.calc(driving_records)

        expect(report_lines.length).to eq(3)
        expect(report_lines[0]).to eq('Terence: 17 miles @ 35 mph')
        expect(report_lines[1]).to eq('Adam: 11 miles @ 43 mph')
        expect(report_lines[2]).to eq('Alma: 0 miles')
      end
    end

    describe 'When there are extremely slow or fast trips' do
      it 'excludes trips with speeds less than 5 mph' do
        driving_records = [
            'Driver Terence',
            'Trip Terence 07:15 08:15 4.9',
            'Driver Adam',
            'Trip Adam 06:30 06:45 10.7'
        ]

        report_lines = calculator.calc(driving_records)

        expect(report_lines.length).to eq(2)
        expect(report_lines[0]).to eq('Adam: 11 miles @ 43 mph')
        expect(report_lines[1]).to eq('Terence: 0 miles')
      end

      it 'excludes trips with speeds greater than 100 mph' do
        driving_records = [
            'Driver Terence',
            'Trip Terence 07:15 07:45 60',
            'Driver Adam',
            'Trip Adam 06:30 06:45 10.7'
        ]

        report_lines = calculator.calc(driving_records)

        expect(report_lines.length).to eq(2)
        expect(report_lines[0]).to eq('Adam: 11 miles @ 43 mph')
        expect(report_lines[1]).to eq('Terence: 0 miles')
      end

    end

  it 'ignores duplicate Driver entries' do
    driving_records = [
        'Driver Terence',
        'Driver Terence',
        'Driver Adam',
        'Driver Adam',
        'Trip Adam 06:30 06:45 10.7'
    ]

    report_lines = calculator.calc(driving_records)
    expect(report_lines.length).to eq(2)
    expect(report_lines[0]).to eq('Adam: 11 miles @ 43 mph')
    expect(report_lines[1]).to eq('Terence: 0 miles')
  end

  it 'ignores entries with unknown commands' do
      driving_records = [
          'Driver Adam',
          'Trip Adam 06:30 06:45 10.7',
          'Passenger Alphonse'
      ]

      report_lines = calculator.calc(driving_records)

      expect(report_lines.length).to eq(1)
      expect(report_lines[0]).to eq('Adam: 11 miles @ 43 mph')
  end

  it 'ignores entries which are not formatted correctly' do
    driving_records = [
        'Driver Terence',
        'Trip Terence 07:15 07:45 60',
        'Driver Adam',
        'Trip Adam zz:30 06:45 10.7'
    ]

    report_lines = calculator.calc(driving_records)

    expect(report_lines.length).to eq(2)
    expect(report_lines[0]).to eq('Terence: 0 miles')
    expect(report_lines[1]).to eq('Adam: 0 miles')
  end
end
